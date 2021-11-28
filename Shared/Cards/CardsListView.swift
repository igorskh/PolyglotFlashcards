//
//  CardsListView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import SwiftUI

struct CardsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Namespace var namespace
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Card>
    
    @State var selectedCard: Card?
    @State var showDetailCard: Bool = false
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
            showDetailCard = false
            selectedCard = destination
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
            
            Button {
                showLanguageFilter = false
            } label: { Text("Set") }
            
            Spacer()
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Polyglot Flashcards")
                        .font(.title)
                    
                    Spacer()
                    
                    Button(action: addCard) {
                        Image(systemName: "plus")
                    }
                    
                    Button(action: { showLanguageFilter.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .sheet(isPresented: $showLanguageFilter) {
                        languageFilter
                            .padding()
                    }
                }
                .padding()
                
                cardsList
            }
            
            if  selectedCard != nil || showDetailCard {
                CardDetailView(
                    card: selectedCard,
                    onClose: { toggleCard() },
                    namespace: namespace
                )
            }
        }
    }
}
