//
//  DecksGridView.swift
//  PolyglotFlashcards (iOS)
//
//  Created by Igor Kim on 06.02.22.
//

import SwiftUI

struct DecksGridView: View {
    @EnvironmentObject var tabRouter: TabRouter
    
    @State var loadingDeckID: ObjectIdentifier?
    @Binding var selectedDeck: Deck?
    var decks: [Deck]
    var namespace: Namespace.ID
    var openDeck: ((_ item: Deck?) -> Void)? = nil
    var showNoCategory: Bool = true
    var topPadding: CGFloat = 80
    var bottomPadding: CGFloat = 50
    
    let columns = [
        GridItem(.adaptive(minimum: 300))
    ]
    
    func openDeckCards(_ item: Deck?) {
        loadingDeckID = item?.id
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                tabRouter.selectedDeck = item
                tabRouter.currentTab = .cards
            }
        }
    }
    
    func deckItemView(item: Deck) -> some View {
        ZStack {
            DeckPreviewView(deck: item, namespace: namespace, show: selectedDeck != nil && selectedDeck!.id == item.id)
                .id(item.id)
                .padding(10)
                .onTapGesture {
                    openDeckCards(item)
                }
                .animatedLongTap(onDismiss: {}) {
                    openDeck?(item)
                }
            
            if let openDeck = openDeck,
               selectedDeck == nil {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            openDeck(item)
                        }) {
                            Image(systemName: "pencil.circle.fill")
                        }
                        .font(.title)
                        .foregroundColor(.white)
                        .opacity(0.6)
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            
            
            if let loadingDeckID = loadingDeckID,
               loadingDeckID == item.id {
                LoadingBackdropView()
            }
        }
    }
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                VStack {}.frame(height: topPadding)
                
                LazyVGrid(columns: columns, spacing: 10) {
                    if showNoCategory {
                        DeckPreviewView(deck: nil, namespace: namespace)
                            .padding(10)
                            .onTapGesture {
                                openDeckCards(nil)
                            }
                    }
                    
                    ForEach(decks) { item in
                        deckItemView(item: item)
                    }
                }
                Spacer()
                    .padding(.bottom, bottomPadding)
            }
            .onAppear {
                if let id = tabRouter.selectedDeck?.id {
                    scrollView.scrollTo(id, anchor: .center)
                }
            }
        }
    }
}
