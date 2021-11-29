//
//  MatchPairsGameScreen.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 29.11.21.
//

import SwiftUI

struct MatchPairsGameScreen: View {
    @Namespace private var animation
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavControllerViewModel
    @EnvironmentObject var game: MatchPairsGame
    
    var stepView: some View {
        Group {
            VStack(spacing: 20) {
                GameCardView(
                    variant: game.gameStep!.mainVariant,
                    selectedIDs: game.selectedVariantIDs,
                    correctID: game.gameStep!.correctVariantID
                )
                    .padding(.bottom)
                
                ForEach(game.gameStep!.variantChoices.indices) { i in
                    GameCardView(
                        variant: game.gameStep!.variantChoices[i],
                        selectedIDs: game.selectedVariantIDs,
                        correctID: game.gameStep!.correctVariantID
                    )
                        .onTapGesture {
                            withAnimation {
                                game.checkStep(variant: game.gameStep!.variantChoices[i]) { _ in }
                            }
                        }
                }
            }
            
            HStack {
                FilledButton(
                    title: "Next",
                    color: game.selectedVariantIDs.contains(game.gameStep!.correctVariantID) ? Color.green.opacity(0.8) : Color.gray
                ) {
                    if game.selectedVariantIDs.contains(game.gameStep!.correctVariantID) {
                        game.nextStep()
                    }
                }
            }
            .padding(.vertical)
            
            Spacer()
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Match Pairs Game")
                    .font(.title)
                
                Spacer()
                
                Button {
                    navigationController.pop(to: .root)
                } label: { Text("Finish") }
            }
            .padding(.bottom)
            
            Text("\(game.numberOfCorrect) of \(game.numberOfAttempts)")
                .fontWeight(.heavy)
                .font(.title)
        
            stepView
            
            Spacer()
        }
        .padding()
    }
}
