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
        case .Italian:
            lang = NLLanguage.italian
        case .Dutch:
            lang = NLLanguage.dutch
        case .Japanese:
            lang = NLLanguage.japanese
        case .Unknown:
            lang = NLLanguage.undetermined
        case .French:
            lang = NLLanguage.french
        case .Greek:
            lang = NLLanguage.greek
        case .Ukrainian:
            lang = NLLanguage.ukrainian
        case .Turkish:
            lang = NLLanguage.turkish
        case .Armenian:
            lang = NLLanguage.armenian
        case .Bulgarian:
            lang = NLLanguage.bulgarian
        case .Croatian:
            lang = NLLanguage.croatian
        case .Czech:
            lang = NLLanguage.czech
        case .Danish:
            lang = NLLanguage.danish
        case .Finnish:
            lang = NLLanguage.finnish
        case .Georgian:
            lang = NLLanguage.georgian
        case .Hebrew:
            lang = NLLanguage.hebrew
        case .Hindi:
            lang = NLLanguage.hindi
        case .Hungarian:
            lang = NLLanguage.hungarian
        case .Icelandic:
            lang = NLLanguage.icelandic
        case .Indonesian:
            lang = NLLanguage.indonesian
        case .Korean:
            lang = NLLanguage.korean
        case .Norwegian:
            lang = NLLanguage.norwegian
        case .Polish:
            lang = NLLanguage.polish
        case .Portuguese:
            lang = NLLanguage.portuguese
        case .Romanian:
            lang = NLLanguage.romanian
        case .Chinese:
            lang = NLLanguage.simplifiedChinese
        case .Slovak:
            lang = NLLanguage.slovak
        case .Swedish:
            lang = NLLanguage.swedish
        case .Thai:
            lang = NLLanguage.thai
        case .Vietnamese:
            lang = NLLanguage.vietnamese
        default:
            lang = NLLanguage.undetermined
        }
        self.init(rawValue: lang.rawValue)
    }
}
