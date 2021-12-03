//
//  MatchPairsStartScreen.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 28.11.21.
//

import SwiftUI

struct MatchPairsStartScreen: View {
    @EnvironmentObject var tabRouter: TabRouter
    
    @Preference(\.languages) var languages
    @EnvironmentObject var navigationController: NavControllerViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var game: MatchPairsGame = .init()
    
    var body: some View {
        ScrollView {
            HStack {
                Text(LocalizedStringKey("Match Pairs Game"))
                    .font(.title)
                Spacer()
            }
            
            Text(LocalizedStringKey("Choos decks to play"))
                .padding(.vertical)
            
            DecksPicker(selectedDecks: $game.selectedDecks, canEdit: false, showAny: true)
            
            Text(LocalizedStringKey("Choose at least 2 variants to play"))
                .padding(.vertical)
            
            
            LanguageFilter(
                languages: languages,
                selected: $game.selectedLanguages
            )
            
            FilledButton(
                title: NSLocalizedString("Start", comment: "Start game"),
                color: game.selectedLanguages.count > 1 ? .green : .gray) {
                    game.start(viewContext: viewContext) {
                        tabRouter.isModal = true
                        navigationController.push(
                            MatchPairsGameScreen()
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

struct MatchPairsGameStartScreen_Previews: PreviewProvider {
    static var previews: some View {
        MatchPairsStartScreen()
    }
}
