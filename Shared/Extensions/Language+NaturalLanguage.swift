//
//  Language+NaturalLanguage.swift
//  PolyglotFlashcards (iOS)
//
//  Created by Igor Kim on 25.11.21.
//

import NaturalLanguage

extension NLLanguage {
    init(_ language: Language) {
        var lang: NLLanguage
        switch language {
        case .English:
            lang = NLLanguage.english
        case .German:
            lang = NLLanguage.german
        case .Russian:
            lang = NLLanguage.russian
        case .Spanish:
            lang = NLLanguage.spanish
        case .Dutch:
            lang = NLLanguage.dutch
        case .Japanese:
            lang = NLLanguage.japanese
        case .Unknown:
            lang = NLLanguage.undetermined
        }
        self.init(rawValue: lang.rawValue)
    }
}
