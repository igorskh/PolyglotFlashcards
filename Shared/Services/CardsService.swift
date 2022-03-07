//
//  CardsService.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 17.12.21.
//

import SwiftUI
import CoreData

class CardsService {
    static var shared = CardsService()
    
    private var viewContext = PersistenceController.shared.container.viewContext
    
    func getDecks(searchText: String? = nil) -> [Deck] {
        let fetchRequest: NSFetchRequest<Deck>
        fetchRequest = Deck.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Deck.text, ascending: true)
        ]
        if let searchText = searchText,
           !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        }
        
        let objects = try? viewContext.fetch(fetchRequest)
        return (objects ?? [])
    }
    
    func cleanOrphanVariants() -> Int {
        let fetchRequest: NSFetchRequest<CardVariant>
        fetchRequest = CardVariant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "card == null")
        
        let objects = try? viewContext.fetch(fetchRequest)
        objects?.forEach({ variant in
            viewContext.delete(variant)
        })
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
            AppLogger.shared.error("Unresolved deleteCard error \(nsError), \(nsError.userInfo)")
        }
        
        return objects?.count ?? 0
    }
    
    func getVariants(text: String) -> [CardVariant] {
        let fetchRequest: NSFetchRequest<CardVariant>
        fetchRequest = CardVariant.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \CardVariant.text, ascending: true)
        ]
        fetchRequest.predicate = NSPredicate(format: "text CONTAINS[cd] %@", text)
        
        let objects = try? viewContext.fetch(fetchRequest)
        return (objects ?? [])
    }
    
    func deleteCard( card: Card?, onFinished: @escaping () -> Void) {
        if let card = card {
            viewContext.delete(card)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
                AppLogger.shared.error("Unresolved deleteCard error \(nsError), \(nsError.userInfo)")
            }
            onFinished()
        }
    }
    
    func saveCard(withImage imageData: Data?,
                  card: Card?,
                  translations: [Translation],
                  decks: [Deck],
                  onFinished: @escaping () -> Void) {
        var newWord: Card?
        if let card = card {
            newWord = card
        } else {
            newWord = Card(context: viewContext)
        }
        if let imageData = imageData {
            newWord?.image = imageData
        }
        
        newWord?.languages = translations.reduce("|", { partialResult, tr in
            return partialResult + tr.target.code + "|"
        })
        newWord?.decks = Set<Deck>(decks) as NSSet
        
        translations.forEach { tr in
            var newWordTranslation: CardVariant?
            var isCreating: Bool = false
            
            newWordTranslation = newWord?.variants?.first(where: {
                ($0 as? CardVariant)?.language_code == tr.target.rawValue
            }) as? CardVariant
            
            if newWordTranslation == nil {
                newWordTranslation = CardVariant(context: viewContext)
                isCreating = true
            }
            
            newWordTranslation!.text = tr.translation
            newWordTranslation!.language_code = tr.target.rawValue
            if isCreating {
                newWord?.addToVariants(newWordTranslation!)
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError.code) \(nsError), \(nsError.userInfo)")
            AppLogger.shared.error("Unresolved saveCard error \(nsError), \(nsError.userInfo)")
        }
        onFinished()
    }
    
    func saveCard(
        selectedImageData: Data,
        card: Card?,
        translations: [Translation],
        decks: [Deck],
        onFinished: @escaping () -> Void) {
            
        var imageData: Data? = nil
            
        if selectedImageData.count > 0 {
            if let image = UIImage(data: selectedImageData)?.scalePreservingAspectRatio(targetSize: CGSize(width: 500, height: 500)),
               let data = image.pngData() {
                imageData = data
            }
        }
        self.saveCard(
            withImage: imageData,
            card: card,
            translations: translations,
            decks: decks,
            onFinished: onFinished
        )
    }
    
    func saveDeck(
        deck: Deck? = nil,
        title: String,
        imageData: Data? = nil,
        onFinished: (String) -> Void
    ) -> Deck? {
        let newDeckTitle = title.trimmingCharacters(in: [" "])
        if newDeckTitle == "" {
            onFinished(NSLocalizedString("Enter deck title", comment: "Enter deck title"))
            return nil
        }
        
        var newDeck: Deck?
        if let deck = deck {
            newDeck = deck
        } else {
            newDeck = Deck(context: viewContext)
        }
        if let imageData = imageData {
            newDeck?.image = imageData
        }
        
        newDeck?.title = newDeckTitle
        
        do {
            try viewContext.save()
            onFinished("")
            return newDeck
        } catch {
            let nsError = error as NSError
            onFinished(nsError.userInfo.description)
            print("Unresolved error \(nsError.code) \(nsError), \(nsError.userInfo)")
            AppLogger.shared.error("Unresolved saveDeck error \(nsError), \(nsError.userInfo)")
            
            return nil
        }
    }
    
    func deleteDeck(deck: Deck?, onFinished: @escaping (String) -> Void) {
        if let deck = deck {
            if let cards = deck.cards,
               cards.count > 0 {
                onFinished(NSLocalizedString("This deck contains cards", comment: "This deck contains cards"))
                return
            }
            
            viewContext.delete(deck)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                onFinished("Unresolved error \(nsError), \(nsError.userInfo)")
                
                AppLogger.shared.error("Unresolved deleteDeck error \(nsError), \(nsError.userInfo)")
            }
            onFinished("")
        }
    }
}
