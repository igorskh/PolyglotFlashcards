//
//  SearchScreenViewModel.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 09.02.22.
//

import Foundation
import Combine
import SwiftUI

enum CardsSearchMode {
    case variants
    case decks
}

class SearchScreenViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var decks: [Deck] = []
    @Published var variants: [CardVariant] = []
    @Published var searchMode: CardsSearchMode = .variants {
        didSet {
            fetch()
        }
    }
    
    private var viewContext = PersistenceController.shared.container.viewContext
    private var searchCancellable: AnyCancellable? = nil
    
    init() {
        searchCancellable = AnyCancellable(
            $searchText
                .removeDuplicates()
                .debounce(for: 0.2, scheduler: DispatchQueue.main)
                .sink { text in
                    self.fetch(with: text)
                }
        )
    }
    
    func fetch(with text: String? = nil) {
        let searchText = text ?? searchText
        withAnimation {
            if searchMode == .variants {
                fetchVariants(searchText)
            } else {
                fetchDecks(searchText)
            }
        }
    }
    
    func fetchDecks(_ searchText: String) {
        let searchText = searchText.trimmingCharacters(in: [" "])
        if searchText == "" {
            decks = []
            return
        }
        decks = CardsService.shared.getDecks(searchText: searchText)
    }
    
    func fetchVariants(_ searchText: String) {
        let searchText = searchText.trimmingCharacters(in: [" "])
        if searchText == "" {
            variants = []
            return
        }
        variants = CardsService.shared.getVariants(text: searchText)
    }
}
