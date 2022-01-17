//
//  DecksGridView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 02.12.21.
//

import SwiftUI
import Combine

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
    @State var scaleValue: CGFloat = 0.0
    
    @State var animationTimer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    @Namespace var namespace
    var routerNamespace: Namespace.ID
    
    let columns = [
        GridItem(.adaptive(minimum: 300))
    ]
    
    func openDeck(_ item: Deck?) {
        withAnimation(.spring()) {
            selectedDeck = item
        }
    }
    
    func openDeckCards(_ item: Deck?) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                tabRouter.selectedDeck = item
                tabRouter.currentTab = .cards
            }
        }
    }
    
    var decksView: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                VStack {}.frame(height: 60)
                
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
                                .scaleEffect(scaleDeckView != nil && scaleDeckView == item ? scaleValue : 1.0)
                                .onTapGesture {
                                    openDeckCards(item)
                                }
                                .onLongPressGesture(maximumDistance: 100, pressing: { state in
                                    scaleValue = 1.0
                                    if state {
                                        animationTimer = Timer.publish (every: 0.01, on: .current, in:
                                                                                .common).autoconnect()
                                        withAnimation(Animation.linear(duration: 1.0)) {
                                            scaleDeckView = item
                                        }
                                    } else {
                                        animationTimer.upstream.connect().cancel()
                                        scaleDeckView = nil
                                    }
                                }) {
                                    scaleDeckView = nil
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
            .onReceive(animationTimer) { _ in
                scaleValue += 0.001
            }
            .onAppear {
                if let id = tabRouter.selectedDeck?.id {
                    scrollView.scrollTo(id, anchor: .center)
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            ZStack {
                decksView
                
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
