//
//  CardDetailViewModel.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import Foundation
import CoreData
#if !os(macOS)
import UIKit
#endif

class CardDetailViewModel: ObservableObject {
    @Published var options: [TranslationOptions] = []
    @Published var translations: [Translation] = []
    @Published var errorMessage: String = ""
    @Published var decks: [Deck]

    @Published var nQueuedRequests: Int = 0
    
    @Published var query: String = ""
    
    private var translator: TranslationService = PolyglotTranslator.shared
    private var cardsService: CardsService = .shared
    private let speechSynth: SpeechSynthesizer = .init()
    private var selectedImageData: Data = .init()
    private let lock = NSLock()
    
    let card: Card?

    @Preference(\.languages) var languages
    
    init(card: Card? = nil) {
        self.card = card
        self.decks = card?.decks?.sortedArray(using: []) as? [Deck] ?? []
        
        options = languages.map { lang in
            return TranslationOptions(
                formality: .auto,
                locale: "",
                isFormalityAvailable: [.German, .Russian, .Spanish, .Polish, .Portuguese, .French, .Italian].contains(lang),
                isLocaleAvailable: [.English, .Portuguese].contains(lang)
            )
        }
        translations = languages.map { lang in
            var translation = ""
            if let card = card {
                let variant = (card.variants?.sortedArray(using: []) as? [CardVariant])?.first { $0.language_code ==  lang.code }
                translation = variant?.text ?? ""
            }
            return Translation(original: "", translation: translation, source: .Unknown, target: lang)
        }
    }
    
    func setImage(from data: Data) {
        selectedImageData = data
    }
    
    func getTranslation(text: String, from source: Language, for target: Language) {
        var sourceLang: Language? = nil
        if source != .Unknown {
            sourceLang = source
        }
        
        let targetIndex = self.languages.firstIndex(of: target)!
        
        translator.Translate(text: text, source: sourceLang, target: target, options: options[targetIndex]) { result in
            switch result {
            case .success(let remoteTranslations):
                DispatchQueue.main.async {
                    guard let translation = remoteTranslations?.first else {
                        self.errorMessage = NSLocalizedString("Could not get translations", comment: "Could not get translations")
                        return
                    }
                    if let index = self.languages.firstIndex(of: translation.target) {
                        if translation.target == .English && self.languages.contains(.English) {
                            self.query = translation.translation
                        }
                        self.translations[index].translation = translation.translation
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
            
            DispatchQueue.main.async {
                self.lock.lock()
                self.nQueuedRequests -= 1
                self.lock.unlock()
            }
        }
    }
    
    func getTranslation(from sourceLanguage: Language) {
        errorMessage = ""
        
        let targetLanguages = self.languages.filter { lang in
            lang != sourceLanguage
        }
        nQueuedRequests = targetLanguages.count
        
        let index = languages.firstIndex(of: sourceLanguage)
        if sourceLanguage == .English || !languages.contains(.English) {
            query = translations[index!].translation
        }
        
        translations.indices.forEach { idx in
            if translations[idx].target != sourceLanguage {
                translations[idx].translation = ""
            }
        }
        
        targetLanguages.forEach {
            getTranslation(text: translations[index!].translation, from: sourceLanguage, for: $0)
        }
    }
    
    func deleteCard(context: NSManagedObjectContext, onFinished: @escaping () -> Void) {
        cardsService.deleteCard(
            context: context,
            card: card,
            onFinished: onFinished
        )
    }
    
    func saveCard(context: NSManagedObjectContext, onFinished: @escaping () -> Void) {
        cardsService.saveCard(
            context: context,
            selectedImageData: selectedImageData,
            card: card,
            translations: translations,
            decks: decks,
            onFinished: onFinished
        )
    }
    
    func speak(at translationID: Int) {
        speechSynth.speak(string: translations[translationID].translation, language: translations[translationID].target.code)
    }
}
