//
//  DeckPreviewView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 02.12.21.
//

import SwiftUI

struct DeckPreviewView: View {
    var deck: Deck?
    var namespace: Namespace.ID
    var show: Bool
//    var cards: [Card]
    
    init(deck: Deck?, namespace: Namespace.ID, show: Bool = false) {
        self.deck = deck
        self.namespace = namespace
        self.show = show
//        cards = deck?.cards?.prefix(3).map { element in
//            return element
//        } as? [Card] ?? []
    }
    
    var body: some View {
        ZStack {
            CardImagesView(title: "", cardImageData: deck?.image)
//            if let deck = deck {
//                ForEach(cards.indices) { i in
//                    CardImagesView(
//                        title: "",
//                        card: cards[i]
//                    )
//                    .offset(y: CGFloat(-10*(cards.count-i-1)))
//                    .matchedGeometryEffect(id: "\(deck.id)-\(cards[i].id)", in: routerNamespace)
//                }
//            } else {
//                CardImagesView(title: "")
//            }
            
            Text(deck?.title ?? NSLocalizedString("Uncategorized", comment: "Uncategorized"))
                .font(.largeTitle)
                .foregroundColor(.white)
        }
        .matchedGeometryEffect(
            id: deck != nil && show ? "deck-header-\(deck!.id)" : "",
            in: namespace,
            isSource: false
        )
    }
}
