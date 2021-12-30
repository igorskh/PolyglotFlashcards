//
//  Language.swift
//  PolyglotFlashcards (iOS)
//
//  Created by Igor Kim on 18.10.21.
//

import Foundation

var defaultActiveLanguages: [Language] = [.English, .Russian, .German]

struct Locale: Codable {
    var code: String
    var name: String
    
    static func all(for language: Language) -> [Locale] {
        switch language {
        case .English:
            return [
                Locale(code: "gb", name: "British"),
                Locale(code: "us", name: "American")
            ]
        case .Portuguese:
            return [
                Locale(code: "pt", name: "European"),
                Locale(code: "br", name: "Brazilian")
            ]
        default:
            return []
        }
    }
}

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
    case Ukrainian = "uk"
    case Turkish = "tr"
    case Armenian = "hy"
    case Bulgarian = "bg"
    case Croatian = "hr"
    case Czech = "cs"
    case Danish = "da"
    case Finnish = "fi"
    case Georgian = "ka"
    case Hebrew = "iw"
    case Hindi = "hi"
    case Hungarian = "hu"
    case Icelandic = "is"
    case Indonesian = "in"
    case Korean = "ko"
    case Norwegian = "no"
    case Polish = "pl"
    case Portuguese = "pt"
    case Romanian = "ro"
    case Chinese = "zh"
    case Slovak = "sk"
    case Swedish = "sv"
    case Thai = "th"
    case Vietnamese = "vi"
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
            .Ukrainian,
            .Turkish,
            .Armenian,
            .Bulgarian,
            .Croatian,
            .Czech,
            .Danish,
            .Finnish,
            .Georgian,
            .Hebrew,
            .Hindi,
            .Hungarian,
            .Icelandic,
            .Indonesian,
            .Korean,
            .Norwegian,
            .Polish,
            .Portuguese,
            .Romanian,
            .Chinese,
            .Slovak,
            .Swedish,
            .Thai,
            .Vietnamese,
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
        case .Ukrainian:
            return "🇺🇦"
        case .Turkish:
            return "🇹🇷"
        case .Armenian:
            return "🇦🇲"
        case .Bulgarian:
            return "🇧🇬"
        case .Croatian:
            return "🇭🇷"
        case .Czech:
            return "🇨🇿"
        case .Danish:
            return "🇩🇰"
        case .Finnish:
            return "🇫🇮"
        case .Georgian:
            return "🇬🇪"
        case .Hebrew:
            return "🇮🇱"
        case .Hindi:
            return "🇮🇳"
        case .Hungarian:
            return "🇭🇺"
        case .Icelandic:
            return "🇮🇸"
        case .Indonesian:
            return "🇮🇩"
        case .Korean:
            return "🇰🇷"
        case .Norwegian:
            return "🇳🇴"
        case .Polish:
            return "🇵🇱"
        case .Portuguese:
            return "🇵🇹"
        case .Romanian:
            return "🇷🇴"
        case .Chinese:
            return "🇨🇳"
        case .Slovak:
            return "🇸🇰"
        case .Swedish:
            return "🇸🇪"
        case .Thai:
            return "🇹🇭"
        case .Vietnamese:
            return "🇻🇳"
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
        case .Ukrainian:
            return "Ukrainian"
        case .Turkish:
            return "Turkish"
        case .Armenian:
            return "Armenian"
        case .Bulgarian:
            return "Bulgarian"
        case .Croatian:
            return "Croatian"
        case .Czech:
            return "Czech"
        case .Danish:
            return "Danish"
        case .Finnish:
            return "Finnish"
        case .Georgian:
            return "Georgian"
        case .Hebrew:
            return "Hebrew"
        case .Hindi:
            return "Hindi"
        case .Hungarian:
            return "Hungarian"
        case .Icelandic:
            return "Icelandic"
        case .Indonesian:
            return "Indonesian"
        case .Korean:
            return "Korean"
        case .Norwegian:
            return "Norwegian"
        case .Polish:
            return "Polish"
        case .Portuguese:
            return "Portuguese"
        case .Romanian:
            return "Romanian"
        case .Chinese:
            return "Chinese"
        case .Slovak:
            return "Slovak"
        case .Swedish:
            return "Swedish"
        case .Thai:
            return "Thai"
        case .Vietnamese:
            return "Vietnamese"
        }
    }
}
