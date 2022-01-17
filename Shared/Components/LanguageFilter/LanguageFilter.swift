//
//  LanguageFilter.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 27.11.21.
//

import SwiftUI

struct LanguageFilter: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: LanguageFilterViewModel
    @State var nextIndex: Int = 0
    
    @Binding var selected: [Language]
    
    var labels: [String] = []
    var maxSelected: Int = 0
    var hideSelected: Bool = false
    var showIndecies: Bool = false
    var selectOne: Bool = false
    
    init(
        languages: [Language],
        maxSelected: Int = 0,
        labels: [String] = [],
        showIndecies: Bool = false,
        selectOne: Bool = false,
        hideSelected: Bool = false,
        selected: Binding<[Language]>
    ) {
        viewModel = .init(languages: languages)
        _selected = selected
        self.showIndecies = showIndecies
        self.labels = labels
        self.selectOne = selectOne
        self.hideSelected = hideSelected
        self.maxSelected = maxSelected
    }
    
    func toggleLanguage(language: Language) {
        if selected.contains(language) {
            selected.removeAll {
                $0 == language
            }
        } else {
            if maxSelected > 0 && selected.count == maxSelected {
                selected[nextIndex] = language
                nextIndex = (nextIndex + 1)%maxSelected
            } else {
                selected.append(language)
            }
        }
    }
    
    func label(of lang: Language) -> String? {
        guard let index = selected.firstIndex(of: lang) else {
            return nil
        }
        if index < labels.count {
            return labels[index]
        }
        
        return "\(index+1)"
    }
    
    var body: some View {
        VStack {
            TextField(LocalizedStringKey("Search language"), text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            ForEach(
                viewModel.searchResults.filter({ lang in
                    !hideSelected || !selected.contains(lang)
                }).sorted(by: { lang1, lang2 in
                    return lang1.name < lang2.name
                }),
                id: \.self) { lang in
                HStack {
                    Text(lang.flag)
                    Text(lang.name)
                    
                    Spacer()
                    
                    if let label = label(of: lang),
                        showIndecies {
                        Text(label)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                    }
                }
                .padding(5.0)
                .background(
                    Color.green.opacity(selected.contains(lang) ? 0.5 : 0.01)
                )
                .onTapGesture {
                    toggleLanguage(language: lang)
                    if selectOne {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
