//
//  GamesScreen.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 28.11.21.
//

import SwiftUI

struct GamesScreen: View {
    var body: some View {
        VStack {
            NavControllerView {
                GamesListView()
            }
            .frame(maxWidth: 600)
        }
        .frame(maxWidth: .infinity)
    }
}

struct GamesListView: View {
    @EnvironmentObject var navigationController: NavControllerViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text(LocalizedStringKey("Choose game type"))
                
                Spacer()
            }
            .font(.title)
            .padding()
            
            FilledButton(title: "Swipe Game", color: .blue) {
                navigationController.push(
                    SwipeGameStartScreen()
                )
            }
            
            FilledButton(title: "Quiz Game", color: .blue) {
                navigationController.push(
                    MatchPairsStartScreen()
                )
                
            }
            Spacer()
        }
    }
}

struct GamesScreen_Previews: PreviewProvider {
    static var previews: some View {
        GamesScreen()
    }
}
