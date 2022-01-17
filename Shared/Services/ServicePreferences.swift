//
//  ServicePreferences.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 16.01.22.
//

import Foundation

struct ServicePreferences: Codable, Equatable {
    var preferGoogleTranslationEngine: Bool
    var preferGoogleTTSEngine: Bool
}
