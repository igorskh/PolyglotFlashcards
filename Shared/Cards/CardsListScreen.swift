//
//  CardsListScreen.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import SwiftUI

struct CardsListScreen: View {    
    @EnvironmentObject var tabRouter: TabRouter
    @Environment(\.managedObjectContext) private var viewContext
    @Namespace var namespace
    
    var routerNamespace: Namespace.ID
    var deck: Deck?
    
    var cardsRequest: FetchRequest<Card>
    private var items: FetchedResults<Card>{cardsRequest.wrappedValue}
    
    @State var selectedCard: Card?
    @State var showDetailCard: Bool = false {
        didSet {
            DispatchQueue.main.async {
                tabRouter.isModal = showDetailCard
            }
        }
    }
    @State var showLanguageFilter: Bool = false
    
    @Preference(\.languages) var languages
    
    @Preference(\.filteredLanguages) var storedFilteredLanguages
    @State var filteredLanguages: [Language] = []
    
    init(deck: Deck? = nil, routerNamespace: Namespace.ID) {
        self.deck = deck
        let predicate: NSPredicate = deck == nil ?
            NSPredicate(format: "decks.@count == 0") :
            NSPredicate(format: "(ANY decks.title == %@)", deck!.title!)
        cardsRequest = FetchRequest(
            entity: Card.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Card.createdAt, ascending: false)],
            predicate: predicate
        )
        
        self.routerNamespace = routerNamespace
        _filteredLanguages = State(wrappedValue: storedFilteredLanguages)
    }
    
    func addCard() {
        withAnimation(.easeInOut) {
            showDetailCard = true
        }
    }
    
    func toggleCard(destination: Card? = nil) {
        withAnimation(.easeInOut) {
            showDetailCard = destination != nil
            selectedCard = destination
        }
    }
    
    
    let columns = [
        GridItem(.adaptive(minimum: 300))
    ]
    
    var cardsGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(items) { item in
                    CardView(
                        word: item,
                        languages: languages,
                        visibleLanguages: filteredLanguages,
                        namespace: namespace,
                        show: selectedCard != nil && selectedCard!.id == item.id
                    )
                        .opacity(selectedCard != nil && selectedCard!.id == item.id ? 0.0 : 1.0)
                        .onTapGesture {
                            toggleCard(destination: item)
                        }
                        .matchedGeometryEffect(id: item.id, in: routerNamespace)
                }
            }
            Spacer()
                .padding(.bottom, 40)
        }
    }
    
    var cardsList: some View {
        ScrollView {
            ForEach(items) { item in
                CardView(
                    word: item,
                    languages: languages,
                    visibleLanguages: filteredLanguages,
                    namespace: namespace,
                    show: selectedCard != nil && selectedCard!.id == item.id
                )
                    .padding()
                    .opacity(selectedCard != nil && selectedCard!.id == item.id ? 0.0 : 1.0)
                    .onTapGesture {
                        toggleCard(destination: item)
                    }
            }
            Spacer()
                .padding(.bottom, 40)
        }
    }
    
    var languageFilter: some View {
        VStack {
            Text("Filter Languages")
                .font(.title)
            
            LanguageFilter(languages: languages, selected: $filteredLanguages)
                .onChange(of: filteredLanguages) {
                    storedFilteredLanguages = $0
                }
            
            FilledButton(title: NSLocalizedString("Set", comment: "Set filter languages"), color: .accentColor) {
                showLanguageFilter = false
            }
            
            Spacer()
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        withAnimation {
                            tabRouter.currentTab = .decks
                        }
                    } label: {
                        Image(systemName: "arrowshape.turn.up.backward")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("\(deck?.title ?? NSLocalizedString("Polyglot Cards", comment: "title"))")
                    
                    Spacer()
                    
                    Button(action: addCard) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { showLanguageFilter.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .font(.title)
                .padding()
                
                cardsGrid
            }
            .sheet(isPresented: $showLanguageFilter) {
                languageFilter
                    .padding()
            }
            
            if  selectedCard != nil || showDetailCard {
                Color.black
                    .opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        toggleCard()
                    }
                
                CardDetailView(
                    deck: deck,
                    card: selectedCard,
                    onClose: { toggleCard() },
                    namespace: namespace
                )
                    .frame(maxHeight: 800)
            }
        }
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded({ value in
            if value.translation.width > 0 && value.startLocation.x < 20 {
                withAnimation {
                    tabRouter.currentTab = .decks
                }
            }
        }))
    }
}
