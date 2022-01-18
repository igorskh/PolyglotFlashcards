//
//  DecksListViewModel.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 15.01.22.
//

import Foundation
import Combine

class DecksListViewModel: ObservableObject {
    let didChange = PassthroughSubject<Void, Never>()
    
    var decks: [Deck]
    var cardsServices: CardsService = .shared
    
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
        decks = cardsServices.getDecks()
        
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
