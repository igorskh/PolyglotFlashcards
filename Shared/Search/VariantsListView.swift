//
//  VariantsListView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 09.02.22.
//

import SwiftUI

struct VariantsListView: View {
    @EnvironmentObject var tabRouter: TabRouter
    var variants: [CardVariant]
    var topPadding: CGFloat = 100
    var bottomPadding: CGFloat = 50
    
    func navigateCard(from variant: CardVariant) {
        tabRouter.currentTab = .cards
        
        tabRouter.selectedDeck = variant.card?.decks?.sortedArray(using: []).first as? Deck
        tabRouter.selectedCard = variant.card
    }
    
    var body: some View {
        ScrollView {
            VStack {}.frame(height: topPadding)
            
            ForEach(variants) { variant in
                HStack {
                    Text(Language(rawValue: variant.language_code ?? "")?.flag ?? "?")
                    Text(variant.text ?? "N/A")
                    
                    Spacer()
                }
                .onTapGesture {
                    navigateCard(from: variant)
                }
                .padding(10)
            }
            
            Spacer()
                .padding(.bottom, bottomPadding)
        }
    }
}
