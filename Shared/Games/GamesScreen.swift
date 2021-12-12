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
                MatchPairsStartScreen()
            }
            .frame(maxWidth: 600)
        }
        .frame(maxWidth: .infinity)
    }
}

struct GamesScreen_Previews: PreviewProvider {
    static var previews: some View {
        GamesScreen()
    }
}
