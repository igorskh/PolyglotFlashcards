//
//  TranslationOptionsEditView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 29.12.21.
//

import SwiftUI

struct TranslationOptionsEditView: View {
    var language: Language
    @Binding var options: TranslationOptions
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text(String(format: NSLocalizedString("Settings for language", comment: "Settings for language"), "\(language.name)"))
                .font(.title)
            
            if options.isLocaleAvailable {
                Text(LocalizedStringKey("Locale"))
                    .font(.title2)
                
                Picker("Locale", selection: $options.locale) {
                    Text(LocalizedStringKey("Auto"))
                        .tag("")
                    ForEach(Locale.all(for: language), id: \.self.code) {
                        Text(LocalizedStringKey($0.name))
                            .tag($0.code)
                    }
                }
                .pickerStyle(.segmented)
                .font(.title2)
                
            }
            if options.isFormalityAvailable {
                Text(LocalizedStringKey("Formality"))
                    .font(.title2)
                Picker("Formality", selection: $options.formality) {
                    Text(LocalizedStringKey("Auto"))
                        .tag(TranslationServiceFormality.auto)
                    Text(LocalizedStringKey("Formal"))
                        .tag(TranslationServiceFormality.formal)
                    Text(LocalizedStringKey("Informal"))
                        .tag(TranslationServiceFormality.informal)
                }
                .pickerStyle(.segmented)
                .font(.title2)
            }
            Spacer()
        }
        .padding()
    }
}
