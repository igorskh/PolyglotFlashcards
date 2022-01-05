//
//  CardListLanguageFilterView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 31.12.21.
//

import SwiftUI

struct CardListLanguageFilterView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var languages: [Language]
    
    @Preference(\.filteredLanguages) var storedFilteredLanguages
    @Binding var filteredLanguages: [Language]
    
    var body: some View {
        
        VStack {
            Text("Filter Languages")
                .font(.title)
            
            LanguageFilter(languages: languages, selected: $filteredLanguages)
                .onChange(of: filteredLanguages) {
                    storedFilteredLanguages = $0
                }
            
            FilledButton(title: NSLocalizedString("Set", comment: "Set filter languages"), color: .accentColor) {
                presentationMode.wrappedValue.dismiss()
            }
            
            Spacer()
        }
    }
}
