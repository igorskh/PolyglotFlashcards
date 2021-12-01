//
//  LanguageFilter.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 27.11.21.
//

import SwiftUI

struct LanguageFilter: View {
    var languages: [Language]
    @Binding var selected: [Language]
    
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
        ForEach(languages, id: \.self) { lang in
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
