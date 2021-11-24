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
    
    @State var showAddCard: Bool = false
    
    @State var selectedCard: Card?
    @State var showDetailCard: Bool = false
    @State var showLanguageFilter: Bool = false
    
    @State var languages: [Language] = Language.all
    @State var visibleLanguages: [Language] = Language.all
    
    func addCard() {
        showAddCard.toggle()
    }
    
    func toggleLanguage(language: Language) {
        if visibleLanguages.contains(language) {
            visibleLanguages.removeAll {
                $0 == language
            }
        } else {
            visibleLanguages.append(language)
        }
    }
    
    func toggleCard(destination: Card? = nil) {
        withAnimation(.easeInOut) {
            showDetailCard.toggle()
            selectedCard = destination
        }
    }
    
    var languageFilter: some View {
        ForEach(Language.all, id: \.self) { lang in
            HStack {
                Text(lang.flag)
                
                Spacer()
                
                Text(lang.name)
            }
            .padding(5.0)
            .background(
                Color.white.opacity(visibleLanguages.contains(lang) ? 0.5 : 0.01)
            )
            .onTapGesture {
                toggleLanguage(language: lang)
            }
        }
    }
    
    var cardsList: some View {
        ScrollView {
            ForEach(items) { item in
                CardView(
                    word: item,
                    languages: languages,
                    visibleLanguages: visibleLanguages,
                    namespace: namespace,
                    isSource: !showDetailCard
                )
                    .padding()
                    .onTapGesture {
                        toggleCard(destination: item)
                    }
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Polyglot Flashcards")
                        .font(.largeTitle)
                    
                    Spacer()
                    
                    Button(action: addCard) {
                        Image(systemName: "plus")
                    }
                    
                    Button(action: { showLanguageFilter.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .sheet(isPresented: $showLanguageFilter) {
                        VStack {
                            Text("Filter Languages")
                                .font(.largeTitle)
                            
                            languageFilter
                            Spacer()
                        }
                        .padding()
                    }
                }
                .padding(.horizontal)
                
                cardsList
            }
            .sheet(isPresented: $showAddCard) {
                CardDetailView(namespace: namespace)
            }
            
            if let selectedCard = selectedCard {
                CardDetailView(card: selectedCard,  onClose: { toggleCard() }, namespace: namespace)
            }
        }
    }
}
