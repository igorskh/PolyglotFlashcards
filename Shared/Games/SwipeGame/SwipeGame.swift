//
//  SwipeGame.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 31.12.21.
//

import SwiftUI
import CoreData

class SwipeGame: ObservableObject {
    @Published var selectedLanguages: [Language] = []
    @Published var selectedDecks: [Deck] = []
    
    @Published var error: String = ""
    @Published var isFinished: Bool = false
    
    @Published var count: Int = 0 {
        didSet {
            withAnimation {
                progressValue = Float(count) / Float(cards.count)
            }
            if count == cards.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        self.isFinished = true
                    }
                    
                }
            } else if count == 0 {
                withAnimation {
                    isFinished = false
                    progressColor = .blue
                }
            }
        }
    }
    @Published var progressValue: Float = 0.0
    @Published var progressColor: Color = .blue
    
    @Published var isFaceUp: Bool = false
    @Published var isNextCard: Bool = false
    @Published var triggerResetCard: Bool = false
    
    var currentCardID: Int = 0
    var gameStep: SwipeGameStep?
    var cards: [Card] = []
    
    private let speechSynth: SpeechSynthesizer = .init()
    
#if !os(macOS)
    private let feedbackGenerator = UINotificationFeedbackGenerator()
#endif
    
    func start(limit: Int = 0, viewContext: NSManagedObjectContext, onSuccess: () -> Void) {
        error = ""
        if selectedLanguages.count != 2 {
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
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let objects = try? viewContext.fetch(fetchRequest)
        cards = (objects ?? []).shuffled()
        
        count = 0
        currentCardID = -1
        
        gameStep  = makeStep()
        
        onSuccess()
    }
    
    
    func makeStep() -> SwipeGameStep? {
        if currentCardID == cards.count-1 {
            return nil
        }
        currentCardID += 1
        
        let currentCard: Card = cards[currentCardID]
        
        let variant1 = currentCard.variants?.first(where: {
            ($0 as? CardVariant)?.language_code == selectedLanguages[0].rawValue
        }) as! CardVariant
        
        let variant2 = currentCard.variants?.first(where: {
            ($0 as? CardVariant)?.language_code == selectedLanguages[1].rawValue
        }) as! CardVariant
    
        speak(variant: variant1)
        
        return SwipeGameStep(variant1: variant1, variant2: variant2)
    }
    
    func nextCard() {
        triggerResetCard = false
        
        withAnimation(Animation.easeIn(duration: 0.2)) {
            isNextCard = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isFaceUp = false
            self.triggerResetCard = true
            
            withAnimation(Animation.easeIn(duration: 0.2)) {
                self.isNextCard = true
            }
            self.count += 1
            self.gameStep = self.makeStep()
            
            self.isNextCard = false
        }
    }
    
    func speak(variant: CardVariant) {
        speechSynth.speak(string: variant.text!, language: variant.language_code!)
    }
}
