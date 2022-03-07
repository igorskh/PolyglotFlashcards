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
        
        let separator: Character = ";"
        let rows = inputText.split(separator: "\n")
        if rows.count < 1 {
            return
        }
            
        let importLanguages = rows[0].split(separator: separator)
        for i in 1..<rows.count {
            let words = rows[i].split(separator: separator)
            if importLanguages.count != words.count {
                continue
            }
            let newCard = Card(context: childContext)
            newCard.variants =  NSSet(array: importLanguages.enumerated().map { el -> CardVariant in
                let newVariant = CardVariant(context: childContext)
                newVariant.language_code = String(el.element)
                newVariant.text = String(words[el.offset])
                return newVariant
            })
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
            
            let newCard = Card(context: persistentContext)
            newCard.variants = NSSet(array: variants.map { el -> CardVariant in
                let newVariant = CardVariant(context: persistentContext)
            
                newVariant.language_code = el.language_code
                newVariant.text = el.text
                return newVariant
            })
        }
        
        do {
            try persistentContext.save()
            inputText = nil
            AppLogger.shared.info(NSLocalizedString("Cards Imported", comment: "Cards Imported"), show: true)
        } catch {
            let nsError = error as NSError
            AppLogger.shared.error("Unresolved saveCard error \(nsError), \(nsError.userInfo)")
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
            VisualEffectView(effect: UIBlurEffect(style: .dark))
                .edgesIgnoringSafeArea(.all)
            VStack {
                header
                
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
