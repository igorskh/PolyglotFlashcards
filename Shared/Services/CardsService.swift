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
    
    func deleteCard(context: NSManagedObjectContext, card: Card?, onFinished: @escaping () -> Void) {
        if let card = card {
            context.delete(card)
            
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            onFinished()
        }
    }
    
    func saveCard(withImage imageData: Data?,
                  context: NSManagedObjectContext,
                  card: Card?,
                  translations: [Translation],
                  decks: [Deck],
                  onFinished: @escaping () -> Void) {
        var newWord: Card?
        if let card = card {
            newWord = card
        } else {
            newWord = Card(context: context)
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
                newWordTranslation = CardVariant(context: context)
                isCreating = true
            }
            
            newWordTranslation!.text = tr.translation
            newWordTranslation!.language_code = tr.target.rawValue
            if isCreating {
                newWord?.addToVariants(newWordTranslation!)
            }
        }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError.code) \(nsError), \(nsError.userInfo)")
        }
        onFinished()
    }
    
    func saveCard(
        context: NSManagedObjectContext,
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
            context: context,
            card: card,
            translations: translations,
            decks: decks,
            onFinished: onFinished
        )
    }
    
    func saveDeck(
        context: NSManagedObjectContext,
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
            newDeck = Deck(context: context)
        }
        if let imageData = imageData {
            newDeck?.image = imageData
        }
        
        newDeck?.title = newDeckTitle
        
        do {
            try context.save()
            onFinished("")
            return newDeck
        } catch {
            let nsError = error as NSError
            onFinished(nsError.userInfo.description)
            print("Unresolved error \(nsError.code) \(nsError), \(nsError.userInfo)")
            return nil
        }
    }
    
    func deleteDeck(context: NSManagedObjectContext, deck: Deck?, onFinished: @escaping (String) -> Void) {
        if let deck = deck {
            if let cards = deck.cards,
               cards.count > 0 {
                onFinished(NSLocalizedString("This deck contains cards", comment: "This deck contains cards"))
                return
            }
            
            context.delete(deck)
            
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                onFinished("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            onFinished("")
        }
    }
}
