//
//  LanguageFilterViewModel.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 09.12.21.
//

import Foundation
import Combine

class LanguageFilterViewModel: ObservableObject {
    let didChange = PassthroughSubject<Void, Never>()
    
    var languages: [Language]
    @Published var searchText: String = ""
    @Published var searchResults: [Language] = []
    
    private var cancellable: AnyCancellable? = nil
    
    func filterLanguages(_ searchText: String) {
        guard searchText != "" else {
            searchResults = languages
            return
        }
        searchResults = languages.filter({ lang in
            lang.name.lowercased().contains(searchText.lowercased())
        })
    }
    
    init(languages: [Language]) {
        self.languages = languages
        searchResults = languages
        
        cancellable = AnyCancellable(
            $searchText
                .removeDuplicates()
                .debounce(for: 0.2, scheduler: DispatchQueue.main)
                .sink { index in
                    self.filterLanguages(index)
                }
        )
    }
}
