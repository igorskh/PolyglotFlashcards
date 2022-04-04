//
//  CardsImportView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 06.03.22.
//

import SwiftUI
import CoreData

struct CardsImportView: View {
    enum ImportingStatus {
        case ready
        case progress
        case finished
    }
    
    let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    let persistentContext = PersistenceController.shared.container.viewContext
    
    @Namespace var namespace
    @State var cards: [Card] = []
    @State var isImporting: [Bool] = []
    
    @State var decks: [Deck] = []
    
    @State var importingStatus: ImportingStatus = .ready
    
    @State var isImportingAll: Bool = true {
        didSet {
            isImporting = isImporting.map { _ in isImportingAll }
        }
    }
    
    @Binding var inputText: String?
    
    @Preference(\.languages) var languages
    @Preference(\.filteredLanguages) var storedFilteredLanguages
    
    func parseCards() {
        guard let inputText = inputText else {
            return
        }

        cards = []
        isImporting = []
        
        let separator: CharacterSet = [";"]
        let rows = inputText.components(separatedBy: "\n")
        
        if rows.count < 2 {
            return
        }
            
        let importLanguages = rows[0].components(separatedBy: separator).map { langCode in
            return langCode.trimmingCharacters(in: CharacterSet(charactersIn: "\r "))
        }
        for i in 1..<rows.count {
            let words = rows[i].components(separatedBy: separator)
            if importLanguages.count != words.count {
                continue
            }
            let newCard = Card(context: childContext)
            
            var cardVariants: [CardVariant] = []
            importLanguages.enumerated().forEach { el in
                let word = words[el.offset].trimmingCharacters(in: .controlCharacters)
                let langCode = el.element.trimmingCharacters(in: .controlCharacters)
                
                if !langCode.isEmpty, !word.isEmpty {
                    let newVariant = CardVariant(context: childContext)
                
                    newVariant.language_code = langCode
                    newVariant.text = word
                    cardVariants.append(newVariant)
                }
            }
            
            newCard.variants =  NSSet(array: cardVariants)
            cards.append(newCard)
            isImporting.append(true)
        }
    }
    
    func importCards() {
        for i in 0..<cards.count {
            if !isImporting[i] {
                continue
            }
            let variants: [CardVariant] = cards[i].variants?.sortedArray(using: []) as? [CardVariant] ?? []
            
            let translations = variants.map { el -> Translation in
                return Translation(
                    original: "",
                    translation: el.text ?? "",
                    source: .Unknown,
                    target: Language(rawValue: el.language_code ?? "") ?? .Unknown
                )
            }
            CardsService.shared.saveCard(withImage: nil, card: nil, translations: translations, decks: decks) {
                inputText = nil
                AppLogger.shared.info(NSLocalizedString("Cards Imported", comment: "Cards Imported"), show: true)
                
            }
        }
    }
    
    var header: some View {
        HStack {
            Text(LocalizedStringKey("Import Cards"))
            
            Spacer()
            
            Button(action: {
                inputText = nil
            }) {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(PlainButtonStyle())
        }
        .font(.title)
        .padding()
    }
    
    var body: some View {
        ZStack {
            Color.primary.colorInvert()
            
            VStack {
                header
                
                DecksPicker(selectedDecks: $decks, canEdit: true, showAny: false)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                HStack {
                    Image(systemName: isImportingAll ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .onTapGesture {
                            isImportingAll.toggle()
                        }
                    
                    
                    Spacer()
                    
                    FilledButton(title: NSLocalizedString("Import", comment: "Import"), color: .accentColor) {
                        importingStatus = .progress
                        importCards()
                    }
                    .disabled(importingStatus != .ready)
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack {
                        ForEach(0..<cards.count, id: \.self) { i in
                            HStack {
                                Image(systemName: isImporting[i] ? "checkmark.circle.fill" : "circle")
                                    .font(.title)
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        isImporting[i].toggle()
                                    }
                                
                                CardView(
                                    word: cards[i],
                                    languages: languages,
                                    visibleLanguages: languages,
                                    namespace: namespace,
                                    show: true,
                                    enableAudio: true
                                )
                                    .contentShape(Rectangle())
                            }
                            
                        }
                        
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        parseCards()
                    }
                }
            }
        }
    }
}
