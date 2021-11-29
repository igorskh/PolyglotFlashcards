//
//  MatchPairsStartScreen.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 28.11.21.
//

import SwiftUI

struct MatchPairsStartScreen: View {
    @Preference(\.languages) var languages
    @EnvironmentObject var navigationController: NavControllerViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var game: MatchPairsGame = .init()
    
    var body: some View {
        VStack {
            HStack {
                Text("Match Pairs Game")
                    .font(.title)
                Spacer()
            }
            
            Text("Choose at least 2 variants to play")
                .padding(.vertical)

            LanguageFilter(
                languages: languages,
                selected: $game.selectedLanguages
            )
            
            FilledButton(
                title: "Start",
                color: game.selectedLanguages.count > 1 ? .green : .gray) {
                    game.start(viewContext: viewContext) {
                        navigationController.push(
                            MatchPairsGameScreen()
                                .environmentObject(game)
                        )
                    }
            }
            .font(.title)
            .padding()
            
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
