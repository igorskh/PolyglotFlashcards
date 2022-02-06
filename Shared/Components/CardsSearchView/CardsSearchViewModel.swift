//
//  CardsSearchViewModel.swift
//  PolyglotFlashcards (iOS)
//
//  Created by Igor Kim on 06.02.22.
//

import Foundation
import Combine

class CardsSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var variants: [CardVariant] = []
    private var viewContext = PersistenceController.shared.container.viewContext
    
    private var searchCancellable: AnyCancellable? = nil
    
    init() {
        searchCancellable = AnyCancellable(
            $searchText
                .removeDuplicates()
                .debounce(for: 0.2, scheduler: DispatchQueue.main)
                .sink { text in
                    self.searchCards(text)
                }
        )
    }
    
    func searchCards(_ text: String) {
        variants = CardsService.shared.getVariants(text: text)
    }
}
