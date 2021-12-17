//
//  OnboardingScreen.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 15.12.21.
//

import SwiftUI
import CoreData

let mockData: [MockCard] = [
    MockCard(
        imageName: "sample_dog",
        translations: [
            Translation(original: "the dog", translation: "the dog", source: .English, target: .English),
            Translation(original: "the dog", translation: "собака", source: .English, target: .Russian),
            Translation(original: "the dog", translation: "der Hund", source: .English, target: .German)
        ]
    ),
    MockCard(
        imageName: "sample_cat",
        translations: [
            Translation(original: "the cat", translation: "the cat", source: .English, target: .English),
            Translation(original: "the cat", translation: "кошка", source: .English, target: .Russian),
            Translation(original: "the cat", translation: "die Katze", source: .English, target: .German)
        ]
    ),
    MockCard(
        imageName: "sample_duck",
        translations: [
            Translation(original: "the duck", translation: "the duck", source: .English, target: .English),
            Translation(original: "the duck", translation: "утка", source: .English, target: .Russian),
            Translation(original: "the duck", translation: "die Ente", source: .English, target: .German)
        ]
    )
]

struct MockCard {
    let imageName: String
    let translations: [Translation]
}

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
}

struct OnboardingScreen: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: OnboardingViewModel = .init()
    
    var body: some View {
        Text("Creating sample data...")
            .onAppear {
                viewModel.createSampleCards(context: viewContext)
            }
    }
}

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen()
    }
}
