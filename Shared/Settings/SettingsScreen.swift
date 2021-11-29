//
//  SettingsScreen.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 27.11.21.
//

import SwiftUI

struct SettingsScreen: View {
    @Preference(\.languages) var languages
    @State var activeLanguages: [Language] = []
    
    init() {
        _activeLanguages = State(wrappedValue: languages)
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Active Languages")
                    .font(.title)
                
                Spacer()
            }
            ScrollView {
                LanguageFilter(languages: Language.all, selected: $activeLanguages)
                    .onChange(of: activeLanguages) {
                        languages = $0
                    }
                
                Spacer()
            }
            .padding()
        }
        .padding()
        
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
    }
}
