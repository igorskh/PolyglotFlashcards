//
//  MatchPairsGameFinishedScreen.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 03.12.21.
//

import SwiftUI

struct MatchPairsGameFinishedScreen: View {
    @EnvironmentObject var tabRouter: TabRouter
    @EnvironmentObject var game: MatchPairsGame
    @EnvironmentObject var navigationController: NavControllerViewModel
    
    var text: String {
        let ratio = Double(game.numberOfCorrect)/Double(game.numberOfAttempts)
        if ratio > 0.9 {
            return "Well done"
        } else if ratio > 0.5 {
            return "Not bad"
        }
        return "Better luck next time"
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(NSLocalizedString(text, comment: "Match pair game result \(text)"))
                .font(.largeTitle)
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .padding(.vertical, 40)
                .foregroundColor(.green)
            
            Text(String(format: NSLocalizedString("Count of correct", comment: "Count of correct"), "\(game.numberOfCorrect)", "\(game.numberOfAttempts)"))
            
            Spacer()
        }
        .onTapGesture {
            tabRouter.isModal = false
            navigationController.pop(to: .root)
        }
    }
}

struct MatchParisGameFinishedScreen_Previews: PreviewProvider {
    static var previews: some View {
        MatchPairsGameFinishedScreen()
    }
}
