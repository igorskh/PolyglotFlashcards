//
//  DecksListViewModel.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 15.01.22.
//

import Foundation
import Combine
import CoreData

class DecksListViewModel: ObservableObject {
    let didChange = PassthroughSubject<Void, Never>()
    
    var viewContext = PersistenceController.shared.container.viewContext
    var decks: [Deck]
    @Published var searchText: String = ""
    @Published var searchResults: [Deck] = []
    
    private var cancellable: AnyCancellable? = nil
    
    func filterDecks(_ searchText: String) {
        guard searchText != "" else {
            searchResults = decks
            return
        }
        searchResults = decks.filter({ deck in
            deck.title!.lowercased().contains(searchText.lowercased())
        })
    }
    
    init() {
        let fetchRequest: NSFetchRequest<Deck>
        fetchRequest = Deck.fetchRequest()
        
        let objects = try? viewContext.fetch(fetchRequest)
        decks = (objects ?? [])
        
        searchResults = decks
        
        cancellable = AnyCancellable(
            $searchText
                .removeDuplicates()
                .debounce(for: 0.2, scheduler: DispatchQueue.main)
                .sink { index in
                    self.filterDecks(index)
                }
        )
    }
}
