//
//  MockData.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 09.01.22.
//

import Foundation

let mockData: [MockCard] = [
    MockCard(
        imageName: "sample_dog",
        translations: [
            Translation(original: "the dog", translation: "the dog", source: .English, target: .English),
            Translation(original: "the dog", translation: "собака", source: .English, target: .Russian),
            Translation(original: "the dog", translation: "der Hund", source: .English, target: .German)
        ]
    ),
    MockCard(
        imageName: "sample_cat",
        translations: [
            Translation(original: "the cat", translation: "the cat", source: .English, target: .English),
            Translation(original: "the cat", translation: "кошка", source: .English, target: .Russian),
            Translation(original: "the cat", translation: "die Katze", source: .English, target: .German)
        ]
    ),
    MockCard(
        imageName: "sample_duck",
        translations: [
            Translation(original: "the duck", translation: "the duck", source: .English, target: .English),
            Translation(original: "the duck", translation: "утка", source: .English, target: .Russian),
            Translation(original: "the duck", translation: "die Ente", source: .English, target: .German)
        ]
    )
]

struct MockCard {
    let imageName: String
    let translations: [Translation]
}
