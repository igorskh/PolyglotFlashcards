//
//  Language.swift
//  PolyglotFlashcards (iOS)
//
//  Created by Igor Kim on 18.10.21.
//

import Foundation

var defaultActiveLanguages: [Language] = [.English, .Russian, .German]

enum Language: String, Codable {
    typealias RawValue = String
    
    case English = "en"
    case German = "de"
    case Russian = "ru"
    case Spanish = "es"
    case Italian = "it"
    case Dutch = "nl"
    case Japanese = "ja"
    case French = "fr"
    case Greek = "el"
    case Unknown = ""
    
    static var all: [Language] {
        return [
            .English,
            .German,
            .Russian,
            .Spanish,
            .Italian,
            .Dutch,
            .Japanese,
            .French,
            .Greek,
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
        case .Japanese:
            return "🇯🇵"
        case .Unknown:
            return "❓"
        case .Italian:
            return "🇮🇹"
        case .French:
            return "🇫🇷"
        case .Greek:
            return "🇬🇷"
        }
    }
    
    var name: String {
        switch self {
        case .Spanish:
            return "Spanish"
        case .Russian:
            return "Russian"
        case .German:
            return "German"
        case .English:
            return "English"
        case .Dutch:
            return "Dutch"
        case .Japanese:
            return "Japanese"
        case .Italian:
            return "Italian"
        case .Unknown:
            return "Unknown"
        case .French:
            return "French"
        case .Greek:
            return "Greek"
        }
    }
}
