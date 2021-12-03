//
//  MatchPairsGame.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 29.11.21.
//

import SwiftUI
import CoreData

class MatchPairsGame: ObservableObject {
    @Published var selectedLanguages: [Language] = []
    
    @Published var selectedDecks: [Deck] = []
    @Published var selectedVariantIDs: [ObjectIdentifier] = []
    
    @Published var numberOfAttempts = 0
    @Published var numberOfCorrect = 0
    @Published var numberOfIncorrect = 0
    
    @Published var triggerCorrect: Bool = false
    @Published var triggerIncorrect: Bool = false
    
    @Published var isAppeared = false
    
    @Published var error: String = ""
    
    var cards: [Card] = []
    
    var gameStep: MatchPairsGameStep?
    var numberOfCards: Int = 4
    
    func start(limit: Int = 0, viewContext: NSManagedObjectContext, onSuccess: () -> Void) {
        error = ""
        if selectedLanguages.count < 2 {
            return
        }
        let fetchRequest: NSFetchRequest<Card>
        fetchRequest = Card.fetchRequest()
        
        var predicates: [NSPredicate] = selectedLanguages.map { lang -> NSPredicate in
            return NSPredicate(format: "languages CONTAINS %@", "|\(lang.code)|")
        }
        
        if !selectedDecks.isEmpty {
            predicates.append(
                NSCompoundPredicate(orPredicateWithSubpredicates: selectedDecks.map({ deck -> NSPredicate in
                    return NSPredicate(format: "(ANY decks.title == %@)", deck.title!)
                }))
            )
        }
//        predicates.append(contentsOf:
//
//        )
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let objects = try? viewContext.fetch(fetchRequest)
        cards = (objects ?? []).shuffled()
        
        numberOfAttempts = 0
        numberOfCorrect = 0
        numberOfIncorrect = 0
        
        nextCard()
        if cards.count > 1 {
            onSuccess()
        } else {
            error = NSLocalizedString("Not enough cards to play", comment: "Not enough cards to play")
        }
    }
    
    func makeStep() -> MatchPairsGameStep? {
        var currentCard: Card?
        if let selectCard = cards.randomElement() {
            currentCard = selectCard
        } else {
            return nil
        }
        let otherCards = cards.filter { c in
            c.id != currentCard!.id
        }[0..<min(cards.count-1, numberOfCards-1)]
        
        let allCards = [Card](([currentCard!] + otherCards).shuffled())
        let selectedLanguage: Language = selectedLanguages.randomElement()!
        
        let mainVariant = currentCard!.variants?.first(where: {
            ($0 as? CardVariant)?.language_code == selectedLanguage.rawValue
        }) as? CardVariant
        
        var correctVariantID: ObjectIdentifier?
        let variantChoices = allCards.map { c -> CardVariant in
            let variants = c.variants?.filter({
                let language_code = ($0 as? CardVariant)?.language_code
                return (language_code != selectedLanguage.rawValue && selectedLanguages.contains(Language(rawValue: language_code!)!))
            }) as! [CardVariant]
            
            let otherVariant = variants.randomElement()!
            if mainVariant!.card == c {
                correctVariantID = otherVariant.id
            }
            return otherVariant
        }.shuffled()
        
        if let mainVariant = mainVariant,
           let correctVariantID = correctVariantID {
            return MatchPairsGameStep(
                mainVariant: mainVariant,
                variantChoices: variantChoices,
                correctVariantID: correctVariantID
            )
        }
        return nil
    }
    
    func nextCard() {
        gameStep = makeStep()
        
        selectedVariantIDs = []
    }
    
    func checkStep(variant: CardVariant, onSuccess: (Bool) -> Void) {
        if selectedVariantIDs.contains(gameStep!.correctVariantID) {
            return nextStep()
        }
        
        if selectedVariantIDs.contains(variant.id) {
            return
        }
        
        numberOfAttempts += 1
        if variant.id == gameStep!.correctVariantID {
            numberOfCorrect += 1
            triggerCorrect = true
        } else {
            numberOfIncorrect += 1
            triggerIncorrect = true
        }
        
        selectedVariantIDs.append(variant.id)
        onSuccess(variant.id == gameStep!.correctVariantID)
    }
    
    func nextStep() {
        nextCard()
    }
}
