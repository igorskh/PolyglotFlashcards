//
//  OnboardingScreen.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 15.12.21.
//

import SwiftUI
import CoreData

class OnboardingViewModel: ObservableObject {
    private var cardsService: CardsService = .shared
    @Preference(\.firstLaunch) var firstLaunch
    
    func createSampleCards(context: NSManagedObjectContext) {
        if let deck = cardsService.saveDeck(context: context, title: "SampleAnimals", onFinished: { _ in }) {
            mockData.forEach { mock in
                guard let img = UIImage(named: mock.imageName) else { return }
                let data = img.pngData()!
                
                cardsService.saveCard(context: context, selectedImageData: data, card: nil, translations: mock.translations, decks: [deck]) {
                    self.firstLaunch = false
                }
            }
        }
    }
    
    func skipOnboarding() {
        firstLaunch = false
    }
}

struct OnboardingScreen: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: OnboardingViewModel = .init()
    
    var body: some View {
        Text("Creating sample data...")
            .onAppear {
                viewModel.skipOnboarding()
            }
    }
}

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen()
    }
}
