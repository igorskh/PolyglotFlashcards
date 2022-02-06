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
//        predicate: NSPredicate(format: "(ANY cards.@count > 0)"),
        animation: .default)
    private var decks: FetchedResults<Deck>
    
    @EnvironmentObject var tabRouter: TabRouter
    @State var showAddDecks: Bool = false
    @State var selectedDeck: Deck? {
        didSet {
            tabRouter.isModal = selectedDeck != nil
        }
    }
    @State var scaleDeckView: Deck?
    @State var isLoading: Bool = false
    
    @Namespace var namespace
    var routerNamespace: Namespace.ID
    
    func openDeck(_ item: Deck?) {
        withAnimation(.spring()) {
            selectedDeck = item
        }
    }
    
    var body: some View {
        ZStack {
            ZStack {
                DecksGridView(
                    selectedDeck: $selectedDeck,
                    isLoading: $isLoading,
                    decks: decks,
                    namespace: namespace,
                    openDeck: openDeck
                )
                
                VStack {
                    HStack {
                        Text(LocalizedStringKey("Polyglot Cards"))
                            .matchedGeometryEffect(id: "router-title", in: routerNamespace)
                        
                        Spacer()
                        
                        Button(action: {
                            showAddDecks.toggle()
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .font(.title)
                    .padding()
                    .background(
                        VisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
                            .edgesIgnoringSafeArea(.all)
                    )
                    .sheet(isPresented: $showAddDecks) {
                        DecksListView(selectedDecks: .constant([]), canEdit: true, canSelect: false)
                    }
                    
                    CardsSearchView()
                    
                    Spacer()
                }
            }
            
            if let deck = selectedDeck {
                VisualEffectView(effect: UIBlurEffect(style: .dark))
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        openDeck(nil)
                    }
                    
                DeckDetailView(deck: deck, namespace: namespace) {
                    withAnimation(.spring()) {
                        selectedDeck = nil
                    }
                }
                .frame(maxWidth: 600, maxHeight: 800)
                
            }
            
            if isLoading {
                LoadingBackdropView()
            }
        }
    }
}
