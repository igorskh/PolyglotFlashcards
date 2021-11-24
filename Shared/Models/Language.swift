//
//  Language.swift
//  PolyglotFlashcards (iOS)
//
//  Created by Igor Kim on 18.10.21.
//

import Foundation

enum Language: String {
    typealias RawValue = String
    
    case English = "en"
    case German = "de"
    case Russian = "ru"
    case Spanish = "es"
    case Dutch = "nl"
    case Unknown = ""
    
    static var all: [Language] {
        return [
            Language.English,
            Language.German,
            Language.Russian,
            Language.Spanish,
            Language.Dutch,
        ]
    }
    
    var code: String {
        return self.rawValue
    }
    
    var flag: String {
        switch self {
        case .Spanish:
            return "🇪🇸"
        case .Russian:
            return "🇷🇺"
        case .German:
            return "🇩🇪"
        case .English:
            return "🇺🇸"
        case .Dutch:
            return "🇳🇱"
        case .Unknown:
            return "❓"
        }
    }
}
