//
//  DecksGridView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 02.12.21.
//

import SwiftUI

struct DecksGridScreen: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Deck.title, ascending: true)],
        predicate: NSPredicate(format: "(ANY cards.@count > 0)"),
        animation: .default)
    private var decks: FetchedResults<Deck>
    
    @EnvironmentObject var tabRouter: TabRouter
    var routerNamespace: Namespace.ID
    
    let columns = [
        GridItem(.adaptive(minimum: 300))
    ]
    
    var decksView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 40) {
                DeckPreviewView(deck: nil, routerNamespace: routerNamespace)
                    .onTapGesture {
                        withAnimation {
                            tabRouter.selectedDeck = nil
                            tabRouter.currentTab = .cards
                        }
                    }
                
                ForEach(decks) { item in
                    DeckPreviewView(deck: item, routerNamespace: routerNamespace)
                        .onTapGesture {
                            withAnimation {
                                tabRouter.selectedDeck = item
                                tabRouter.currentTab = .cards
                            }
                        }
                    
                }
            }
            Spacer()
                .padding(.bottom, 40)
        }
    }
    
    var body: some View {
        VStack {
            
            HStack {
                Text("PolyCard")
                    .matchedGeometryEffect(id: "router-title", in: routerNamespace)
                
                Spacer()
            }
            .font(.title)
            .padding()
            
            decksView
        }
    }
}
