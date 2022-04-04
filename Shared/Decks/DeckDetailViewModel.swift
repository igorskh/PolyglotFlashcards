//
//  DeckDetailViewModel.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 15.01.22.
//

import CoreData

class DeckDetailViewModel: ObservableObject {
    private let viewContext = PersistenceController.shared.container.viewContext
    private var cardsService: CardsService = .shared
    
    var deck: Deck
    
    @Published var deckImage: Data?
    @Published var cardsCount: Int
    @Published var deckTitle: String
    @Published var errorText: String
    
    @Published var showDeleteConfirm: Bool = false
    @Published var deckToDelete: Deck? = nil
    
    init(deck: Deck) {
        self.deck = deck
        self.deckTitle = deck.title ?? ""
        self.deckImage = deck.image
        self.errorText = ""
        
        cardsCount = 0
        getCardsCount()
    }
    
    func getCardsCount() {
        let fetchRequest: NSFetchRequest<Card>
        fetchRequest = Card.fetchRequest()
        
        let predicate: NSPredicate = NSPredicate(format: "(ANY decks.title == %@)", deck.title!)
        fetchRequest.predicate = predicate
        
        do {
            cardsCount = try viewContext.count(for: fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getRandomCardImage() -> Data? {
        if cardsCount == 0 {
            return nil
        }
        let fetchRequest: NSFetchRequest<Card>
        fetchRequest = Card.fetchRequest()
        
        let predicate: NSPredicate = NSPredicate(format: "(ANY decks.title == %@)", deck.title!)
        fetchRequest.predicate = predicate

        do {
            cardsCount = try viewContext.count(for: fetchRequest)
            
            fetchRequest.fetchLimit = 1
            fetchRequest.fetchOffset = Int.random(in: 0..<cardsCount)
            let card = try viewContext.fetch(fetchRequest).first
            return card?.image
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func setRandomCardImage() {
        deckImage = getRandomCardImage()
    }
    
    func saveDeck(onFinished: @escaping (Bool) -> Void) {
        _ = cardsService.saveDeck(
            deck: deck,
            title: deckTitle,
            imageData: deckImage) { message in
                self.errorText = message
                onFinished(message == "")
            }
    }
    
    func deleteDeck(confirmed: Bool = false, onFinished: @escaping (Bool) -> Void) {
        if let cards = deck.cards,
           cards.count > 0 {
            if !confirmed {
                showDeleteConfirm = true
                return
            }
        }
        
        cardsService.deleteDeck(deck: deck, deleteCards: true) { message in
            self.errorText = message
            onFinished(message == "")
        }
        showDeleteConfirm = false
    }
}
