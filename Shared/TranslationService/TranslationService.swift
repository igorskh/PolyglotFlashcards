//
//  TranslationService.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import Foundation

struct Translation: Identifiable {
    var original: String
    var translation: String
    var source: Language
    var target: Language
    
    var id: String {
        "\(source)_\(target)_\(translation)"
    }
}

protocol TranslationService {
    func Translate(text: String, source: Language?, target: Language, onResponse: @escaping (Result<[Translation]?, Error>) -> Void)
}
