//
//  SwipeGameStartScreen.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 31.12.21.
//

import SwiftUI

struct SwipeGameStartScreen: View {
    @EnvironmentObject var tabRouter: TabRouter
    
    @Preference(\.languages) var languages
    @EnvironmentObject var navigationController: NavControllerViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var game: SwipeGame = .init()
    
    var body: some View {
        ScrollView {
            HStack {
                Button {
                    withAnimation {
                        navigationController.pop()
                    }
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .buttonStyle(PlainButtonStyle())
                
                Text(LocalizedStringKey("Swipe Cards Game"))
                Spacer()
            }
            .font(.title)
            
            Text(LocalizedStringKey("Choos decks to play"))
                .padding(.vertical)
            
            DecksPicker(selectedDecks: $game.selectedDecks, canEdit: false, showAny: true)
            
            Text(LocalizedStringKey("Choose 2 variants to play"))
                .padding(.vertical)
            
            
            LanguageFilter(
                languages: languages,
                selected: $game.selectedLanguages
            )
            
            FilledButton(
                title: NSLocalizedString("Start", comment: "Start game"),
                color: game.selectedLanguages.count == 2 ? .green : .gray) {
                    game.start(viewContext: viewContext) {
                        tabRouter.isModal = true
                        navigationController.push(
                            SwipeGameScreen()
                                .environmentObject(game)
                        )
                    }
            }
            .font(.title)
            .padding()
            
            if game.error != "" {
                Text(game.error)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct SwipeGameStartScreen_Previews: PreviewProvider {
    static var previews: some View {
        SwipeGameStartScreen()
    }
}
