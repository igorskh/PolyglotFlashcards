//
//  MatchPairsGameScreen.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 29.11.21.
//

import SwiftUI

struct MatchPairsGameScreen: View {
    @Namespace private var animation
    @EnvironmentObject var tabRouter: TabRouter
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavControllerViewModel
    @EnvironmentObject var game: MatchPairsGame
    
    var stepView: some View {
        Group {
            VStack(spacing: 20) {
                Text(game.gameStep!.mainVariant.text ?? "N/A")
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60, alignment: .center)
                    .animation(game.isAppeared ? nil : .default)
                
                ForEach(game.gameStep!.variantChoices.indices) { i in
                    GameCardView(
                        variant: game.gameStep!.variantChoices[i],
                        selectedIDs: game.selectedVariantIDs,
                        correctID: game.gameStep!.correctVariantID,
                        isAnimated: game.isAppeared
                    )
                        .onTapGesture {
                            withAnimation {
                                game.checkStep(variant: game.gameStep!.variantChoices[i]) { _ in }
                            }
                        }
                }
            }
            
            Spacer()
        }
    }
    
    var body: some View {
        ScrollView {
            HStack {
                Text(LocalizedStringKey("Match Pairs Game"))
                    .font(.title)
                
                Spacer()
                
                Button {
                    navigationController.push(
                        MatchPairsGameFinishedScreen()
                            .environmentObject(game)
                    )
                } label: {
                    Text(LocalizedStringKey("Finish"))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom)
            
            
            HStack {
                Group {
                    BouncingIcon(trigger: $game.triggerCorrect, color: .green, systemName: "checkmark.circle.fill")
                    
                    Text("\(game.numberOfCorrect)")
                        .fontWeight(.heavy)
                        .font(.title2)
                        .animation(game.isAppeared ? nil : .default)
                        .frame(width: 50)
                }
                Spacer()
                Group {
                    Text("\(game.numberOfIncorrect)")
                        .fontWeight(.heavy)
                        .font(.title2)
                        .animation(game.isAppeared ? nil : .default)
                        .frame(width: 50)
                
                    BouncingIcon(trigger: $game.triggerIncorrect, color: .red, systemName: "xmark.circle.fill")
                        .frame(width: 50)
                }
            }
            .onAppear {
                game.isAppeared = true
            }
            .onDisappear {
                game.isAppeared = false
            }
            
            stepView
            
            Spacer()
        }
        .padding()
    }
}
