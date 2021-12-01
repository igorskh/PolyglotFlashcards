//
//  CardsListView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import SwiftUI

struct CardsListView: View {
    @EnvironmentObject var tabRouter: TabRouter
    @Environment(\.managedObjectContext) private var viewContext
    @Namespace var namespace
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.createdAt, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Card>
    
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
    
    init() {
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
            
            FilledButton(title: "Set", color: .accentColor) {
                showLanguageFilter = false
            }
            
            Spacer()
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Polyglot Flashcards")
                    
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
                .foregroundColor(.primary)
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
                
                CardDetailView(
                    card: selectedCard,
                    onClose: { toggleCard() },
                    namespace: namespace
                )
            }
        }
    }
}
