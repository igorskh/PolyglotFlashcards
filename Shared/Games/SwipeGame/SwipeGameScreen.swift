//
//  SwipeGameScreen.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 31.12.21.
//

import SwiftUI

struct SwipeGameScreen: View {
    @EnvironmentObject var tabRouter: TabRouter
    @EnvironmentObject var navigationController: NavControllerViewModel
    @EnvironmentObject var game: SwipeGame
    
    @State var cardStatus: CardStatus = .undefined
    
    @State var cardStatusText: String = "Swipe card"
    
    var backgroundColor: Color {
#if os(macOS)
        return Color(NSColor.controlBackgroundColor)
#endif
        
#if os(iOS)
        return Color(UIColor.systemBackground)
#endif
    }
    
    func goToRoot() {
        tabRouter.isModal = false
        navigationController.pop(to: .root)
    }
    
    var cardsView: some View {
        ScrollView {
            HStack {
                Text(LocalizedStringKey("Swipe Cards Game"))
                    .font(.title)
                Spacer()
                FilledButton(title: NSLocalizedString("Finish", comment: "Finish"), color: Color.red)  {
                    withAnimation {
                        game.isFinished = true
                    }
                }
            }
            
            ProgressBar(value: $game.progressValue, color: $game.progressColor)
                .frame(height: 20)
            
            Text("\(game.count) / \(game.cards.count)")
                .font(.title2)
            
            HStack {
                VStack { }
                .frame(width: 15, height: 400)
                .cornerRadius(20)
                .zIndex(1)
                
                Spacer()
                
                if game.count < game.cards.count {
                    VStack {
                        VStack {
                            Text(LocalizedStringKey("Swipe card"))
                                .font(.title)
                                .transition(.scale)
                        }
                        .frame(height: 60)
                        .padding(.bottom, 40)
                        
                        SwipeGameCardView(
                            status: $cardStatus,
                            variant1: game.gameStep!.variant1,
                            variant2: game.gameStep!.variant2,
                            onCardFlip: { isFlipped in
                                game.speak(variant: isFlipped ? game.gameStep!.variant2 : game.gameStep!.variant1)
                        })
                        
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .onTapGesture {
                                    cardStatus = .notLearned
                                    game.nextCard()
                                }
                            
                            Spacer()
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .onTapGesture {
                                    cardStatus = .learned
                                    game.nextCard()
                                }
                        }
                        .font(.custom("", size: 60))
                        .padding()
                        .padding(.top, 40)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    var finishedView: some View {
        Group {
            VStack {
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColor)
            .transition(.scale)
            
            VStack {
                VStack {
                    Text(LocalizedStringKey("Well done"))
                        .foregroundColor(.white)
                        .font(.title)
                        .fontWeight(.bold)
                }
                .frame(width: 300, height: 250)
                .background(Color.green)
                .cornerRadius(20)
                .onTapGesture {
                    goToRoot()
                }
                
                FilledButton(title: NSLocalizedString("Continue", comment: "Continue"), color: .green, action: {
                    goToRoot()
                })
            }
            
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                if !game.isFinished {
                    cardsView
                        .transition(.scale)
                } else {
                    finishedView
                        .transition(.scale)
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct SwipeGameScreen_Previews: PreviewProvider {
    static var previews: some View {
        SwipeGameScreen()
    }
}
