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
    
    var languageFilter: some View {
        HStack {
            ForEach(Language.all, id: \.self) { lang in
                Text(lang.flag)
                    .padding(5.0)
                    .background(
                        Color.white.opacity(visibleLanguages.contains(lang) ? 1.0 : 0.5)
                    )
                    .onTapGesture {
                        toggleLanguage(language: lang)
                    }
                
            }
        }
    }
    
    var cardsList: some View {
        ScrollView {
            ForEach(items) { item in
                NavigationLink(destination: {
                    AddCardView(card: item)
                }) {
                    CardView(word: item, languages: languages, visibleLanguages: visibleLanguages)
                        .padding()
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                languageFilter
                
                cardsList
                    .navigationTitle("Polyglot Cards")
            }
            .sheet(isPresented: $showAddCard) {
                AddCardView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addCard) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }
}
