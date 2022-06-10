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
    @ObservedObject var game: MatchPairsGame = .init()
    
    var body: some View {
        ScrollView {
            HStack {
                Button {
                    withAnimation {
                        navigationController.pop()
                    }
                } label: {
                    Image(systemName: "chevron.backward.circle.fill")
                }
                .buttonStyle(PlainButtonStyle())
                
                Text(LocalizedStringKey("Quiz Game"))
                Spacer()
            }
            .font(.title)
            
            Text(LocalizedStringKey("Choos decks to play"))
                .padding(.vertical)
            
            DecksPicker(selectedDecks: $game.selectedDecks, canEdit: false, showAny: true)
            
            HStack {
                Toggle("Show images", isOn: $game.showImages)
            }
            .padding(5)
            
            Text(LocalizedStringKey("Choose at least 2 variants to play"))
                .padding(.vertical)
            
            
            LanguageFilter(
                languages: languages,
                selected: $game.selectedLanguages
            )
            
            FilledButton(
                title: NSLocalizedString("Start", comment: "Start game"),
                color: game.selectedLanguages.count > 1 ? .green : .gray) {
                    game.start() {
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
