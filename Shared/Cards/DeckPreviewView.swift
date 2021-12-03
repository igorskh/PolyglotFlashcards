//
//  DeckPreviewView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 02.12.21.
//

import SwiftUI

struct DeckPreviewView: View {
    var routerNamespace: Namespace.ID
    
    var deck: Deck?
    var cards: [Card]
    
    init(deck: Deck?, routerNamespace: Namespace.ID) {
        self.deck = deck
        self.routerNamespace = routerNamespace
        
        cards = deck?.cards?.prefix(3).map { element in
            return element
        } as? [Card] ?? []
    }
    
    var body: some View {
        ZStack {
            if deck == nil {
                CardImagesView(title: NSLocalizedString("Uncategorized", comment: "Uncategorized"))
                    .font(.largeTitle)
            }
            
            ForEach(cards.indices) { i in
                CardImagesView(
                    title: deck?.title ?? NSLocalizedString("Uncategorized", comment: "Uncategorized"),
                    card: cards[i]
                )
                .font(.largeTitle)
                .offset(y: CGFloat(-10*(cards.count-i-1)))
                .matchedGeometryEffect(id: cards[i].id, in: routerNamespace)
            }
        }
    }
}
