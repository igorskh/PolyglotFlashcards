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
    @ObservedObject var game: SwipeGame = .init()
    
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
                
                Text(LocalizedStringKey("Swipe Cards Game"))
                Spacer()
            }
            .font(.title)
            
            Text(LocalizedStringKey("Choos decks to play"))
                .padding(.vertical)
            
            DecksPicker(
                selectedDecks: $game.selectedDecks,
                canEdit: false,
                showAny: true
            )
            
            Text(LocalizedStringKey("Choose cards front and back side languages"))
                .padding(.vertical)
            
            
            LanguageFilter(
                languages: languages,
                maxSelected: 2,
                labels: [
                    NSLocalizedString("Front", comment: ""),
                    NSLocalizedString("Back", comment: "")
                ],
                showIndecies: true,
                selected: $game.selectedLanguages
            )
            
            FilledButton(
                title: NSLocalizedString("Start", comment: "Start game"),
                color: game.selectedLanguages.count == 2 ? .green : .gray) {
                    game.start() {
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
