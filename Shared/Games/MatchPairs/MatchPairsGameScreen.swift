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
    @EnvironmentObject var navigationController: NavControllerViewModel
    @EnvironmentObject var game: MatchPairsGame
    
    var stepView: some View {
        Group {
            VStack {
                if game.showImages,
                   let image = game.gameStep!.mainVariant.card?.image,
                   let uiImage = UIImage(data: image) {
                    Image(image: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: 150)
                        .clipped()
                        .animation(nil)
                        .background(
                            Color.red
                        )
                }
                
                HStack {
                    Text(game.gameStep!.mainVariant.text ?? "N/A")
                        .fontWeight(.heavy)
                        .frame(height: 60, alignment: .center)
                        .animation(game.isAppeared ? nil : .default)
                    
                    Button {
                        game.speak(variant: game.gameStep!.mainVariant)
                    } label: {
                        Image(systemName: "speaker.wave.3")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                VStack(spacing: 20) {
                    ForEach(game.gameStep!.variantChoices.indices) { i in
                        GameCardView(
                            variant: game.gameStep!.variantChoices[i],
                            selectedIDs: game.selectedVariantIDs,
                            correctID: game.gameStep!.correctVariantID,
                            isAnimated: game.isAppeared
                        )
                            .foregroundColor(.white)
                            .onTapGesture {
                                withAnimation {
                                    game.checkStep(variant: game.gameStep!.variantChoices[i]) { _ in }
                                }
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
                
                FilledButton(title: NSLocalizedString("Finish", comment: "Finish"), color: Color.red)  {
                    navigationController.push(
                        MatchPairsGameFinishedScreen()
                            .environmentObject(game)
                    )
                }
            }
            .zIndex(1)
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
            
            FilledButton(title: NSLocalizedString("Continue", comment: "Continue"), color: .green) {
                game.nextStep()
            }
            .disabled(!game.isCorrectSelected)
            
            Spacer()
        }
        .padding()
    }
}
