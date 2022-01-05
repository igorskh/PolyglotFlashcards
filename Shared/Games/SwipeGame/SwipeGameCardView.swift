//
//  SwipeGameCardView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 31.12.21.
//

import SwiftUI

enum CardStatus {
    case undefined
    case learned
    case notLearned
}

struct SwipeGameCardView: View {
    @EnvironmentObject var game: SwipeGame
    
    @State private var rotation = 0.0
    @State private var offset = CGSize.zero
    @State private var tintColor: Color = .gray
    @State private var isTextHidden: Bool = false
    
    @Binding var status: CardStatus
    
    var variant1: CardVariant
    var variant2: CardVariant
    
    var onCardFlip: (Bool) -> Void
    
    func resetCard() {
        status = .undefined
        offset = .zero
        tintColor = .blue
        
        game.triggerResetCard = false
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Text((isTextHidden ? "" : (game.isFaceUp ? variant2.text : variant1.text))!)
                .fontWeight(.bold)
                .font(.title)
            
            Spacer()
            
            HStack {
                Spacer()
                Button {
                    onCardFlip(game.isFaceUp)
                } label: {
                    Image(systemName: "speaker.wave.3")
                        .font(.title2)
                }
                .padding(.vertical)
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
        }
        .onChange(of: game.triggerResetCard) {
            if $0 {
                resetCard()
            }
        }
        .foregroundColor(.white)
        .rotation3DEffect(
            .degrees(game.isFaceUp ? 0: 180),
            axis: (0,1,0),
            perspective: 0.3
        )
        .frame(width: 300, height: 250)
        .background(
            ZStack {
                tintColor
                Color.blue .opacity(2 - Double(abs(offset.width / 40)))
            }
        )
        .cornerRadius(20)
        .scaleEffect(game.isNextCard ? 0.001 : 1)
        .rotationEffect(game.triggerResetCard ? .degrees(0) : .degrees(Double(offset.width / 5)), anchor: .bottom)
        .offset(x:
            game.isNextCard && !game.triggerResetCard ? (
                (game.isFaceUp ? -1 : 1) * (status == .learned ? -200 : 200)
            ) : 0
        )
        .gesture(
            DragGesture(minimumDistance: 1, coordinateSpace: .local)
                .onChanged { gesture in
                    self.offset = gesture.translation
                    if self.offset.width > 0 {
                        status = game.isFaceUp ? .learned : .notLearned
                        
                        tintColor = game.isFaceUp ? .green : .red
                    } else {
                        status = game.isFaceUp ? .notLearned : .learned
                        
                        tintColor = game.isFaceUp ? .red : .green
                    }
                }
                .onEnded { _ in
                    if abs(self.offset.width) > 100 {
                        game.nextCard()
                    } else {
                        withAnimation {
                            resetCard()
                        }
                    }
                }
        )
        .onTapGesture {
            isTextHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isTextHidden = false
            }
            withAnimation {
                game.isFaceUp.toggle()
                onCardFlip(game.isFaceUp)
            }
        }
        .rotation3DEffect(
            .degrees(game.isFaceUp ? 0: 180),
            axis: (0,1,0),
            perspective: 0.3
        )
    }
}
