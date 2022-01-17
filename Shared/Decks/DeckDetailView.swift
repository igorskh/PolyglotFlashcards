//
//  DeckDetailView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 15.01.22.
//

import SwiftUI

struct DeckDetailView: View {
    @ObservedObject var viewModel: DeckDetailViewModel
    var namespace: Namespace.ID
    
    var onClose: () -> Void
    
    init(deck: Deck, namespace: Namespace.ID, onClose: @escaping () -> Void) {
        viewModel = .init(deck: deck)
        self.onClose = onClose
        self.namespace = namespace
    }
    
    var buttons: some View {
        HStack {
            FilledButton(
                title: NSLocalizedString("Save", comment: "Save Deck"),
                color: Color.accentColor
            ) {
                viewModel.saveDeck { success in
                    if success {
                        onClose()
                    }
                }
            }
        
            FilledButton(
                title: NSLocalizedString("Delete", comment: "Delete Card"),
                color: Color.red
            ) {
                viewModel.deleteDeck { success in
                    if success {
                        onClose()
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                CardImagesView(title: "", cardImageData: viewModel.deckImage)
                    .matchedGeometryEffect(id: "deck-header-\(viewModel.deck.id)", in: namespace)
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: { onClose() } ) {
                            Image(systemName: "xmark.circle.fill")
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button(action: { viewModel.setRandomCardImage() } ) {
                            Image(systemName: "dice.fill")
                        }
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.white)
                .font(.title)
                .opacity(0.7)
                .padding(5)
            }
            .frame(maxHeight: 150)
            
            if viewModel.errorText != "" {
                Text(viewModel.errorText)
                    .foregroundColor(.red)
                    .padding()
            }
            
            TextField("", text: $viewModel.deckTitle)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            buttons
                .padding()
            
            Spacer()
        }
        .background(
            Rectangle()
                .ignoresSafeArea()
                .colorInvert()
        )
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if gesture.translation.height > 50 {
                        onClose()
                    }
                }
        )
    }
}
