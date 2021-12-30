//
//  TextToSpeechService.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 30.12.21.
//

import Foundation

protocol TextToSpeechService {
    func Generate(text: String, language: String, onResponse: @escaping (Result<Data?, Error>) -> Void) -> Void
}
