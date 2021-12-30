//
//  LanguageFilter.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 27.11.21.
//

import SwiftUI

struct LanguageFilter: View {
    @ObservedObject var viewModel: LanguageFilterViewModel
    
    @Binding var selected: [Language]
    
    init(languages: [Language], selected: Binding<[Language]>) {
        viewModel = .init(languages: languages)
        _selected = selected
    }
    
    func toggleLanguage(language: Language) {
        if selected.contains(language) {
            selected.removeAll {
                $0 == language
            }
        } else {
            selected.append(language)
        }
    }
    
    var body: some View {
        VStack {
            TextField(LocalizedStringKey("Search language"), text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            ForEach(viewModel.searchResults.sorted(by: { lang1, lang2 in
                return lang1.name < lang2.name
            }), id: \.self) { lang in
                HStack {
                    Text(lang.flag)
                    Text(lang.name)
                    Spacer()
                }
                .padding(5.0)
                .background(
                    Color.green.opacity(selected.contains(lang) ? 0.5 : 0.01)
                )
                .onTapGesture {
                    toggleLanguage(language: lang)
                }
            }
        }
    }
}
