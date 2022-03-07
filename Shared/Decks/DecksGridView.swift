//
//  DecksGridView.swift
//  PolyglotFlashcards (iOS)
//
//  Created by Igor Kim on 06.02.22.
//

import SwiftUI

struct DecksGridView: View {
    @EnvironmentObject var tabRouter: TabRouter
    
    @Binding var selectedDeck: Deck?
    @Binding var isLoading: Bool
    var decks: FetchedResults<Deck>
    var namespace: Namespace.ID
    var openDeck: (_ item: Deck?) -> Void
    
    let columns = [
        GridItem(.adaptive(minimum: 300))
    ]
    
    func openDeckCards(_ item: Deck?) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                tabRouter.selectedDeck = item
                tabRouter.currentTab = .cards
            }
        }
    }
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                VStack {}.frame(height: 100)
                
                LazyVGrid(columns: columns, spacing: 10) {
                    DeckPreviewView(deck: nil, namespace: namespace)
                        .padding(10)
                        .onTapGesture {
                            openDeckCards(nil)
                        }
                    
                    ForEach(decks) { item in
                        ZStack {
                            DeckPreviewView(deck: item, namespace: namespace, show: selectedDeck != nil && selectedDeck!.id == item.id)
                                .id(item.id)
                                .padding(10)
                                .onTapGesture {
                                    openDeckCards(item)
                                }
                                .animatedLongTap(onDismiss: {}) {
                                    openDeck(item)
                                }
                            
                            if selectedDeck == nil {
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
                        }
                    }
                }
                Spacer()
                    .padding(.bottom, 50)
            }
            .onAppear {
                if let id = tabRouter.selectedDeck?.id {
                    scrollView.scrollTo(id, anchor: .center)
                }
            }
        }
    }
}
