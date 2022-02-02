//
//  CardDetailViewModel.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import SwiftUI
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
    
    @Published var isTranslationFieldFocused: Bool = false
    @Published var isHeaderHidden: Bool = false
    
    private var translator: TranslationService = PolyglotTranslator.shared
    private var cardsService: CardsService = .shared
    private let speechSynth: SpeechSynthesizer = .shared
    
    private var selectedImageData: Data = .init()
    private let lock = NSLock()
    private var tasks: [URLSessionDataTask?] = []
    
    let card: Card?

    @Preference(\.languages) var languages
    @Preference(\.servicePreferences) var servicePreferences
    
    init(card: Card? = nil) {
        self.card = card
        self.decks = card?.decks?.sortedArray(using: []) as? [Deck] ?? []
        
        tasks = languages.map { _ in
            nil
        }
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
    
#if !os(macOS)
    func adjustForKeyboard(notification: Notification) {
        withAnimation {
            if notification.name == UIResponder.keyboardWillHideNotification {
                isHeaderHidden = false
            } else if isTranslationFieldFocused {
                if let userInfo = notification.userInfo,
                   let keyboardEndRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                   keyboardEndRect.height > 100 {
                    isHeaderHidden = true
                }
            }
        }
    }
#endif
    
    func setImage(from data: Data) {
        selectedImageData = data
    }
    
    func getTranslation(translationIndex: Int, from source: Language, for target: Language, engine: PolyglotTranslatorEngine = .auto) {
        let targetIndex = self.languages.firstIndex(of: target)!
        
        var options = options[targetIndex]
        options.engine = engine
        
        var sourceLang: Language? = nil
        if source != .Unknown {
            sourceLang = source
        }
        
        let text = translations[translationIndex].translation
            
        tasks[targetIndex]?.cancel()
        tasks[targetIndex] = translator.Translate(text: text, source: sourceLang, target: target, options: options) { result in
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
    
    func getTranslation(from sourceLanguage: Language, engine: PolyglotTranslatorEngine = .auto) {
        errorMessage = ""
        
        let index = languages.firstIndex(of: sourceLanguage)
        if sourceLanguage == .English || !languages.contains(.English) {
            query = translations[index!].translation
        }
        
        var requestTargetLanguages: [Language] = []
        translations.indices.forEach { idx in
            if translations[idx].target != sourceLanguage && translations[idx].translation.isEmpty {
                requestTargetLanguages.append(translations[idx].target)
            }
        }
        nQueuedRequests = requestTargetLanguages.count
        
        requestTargetLanguages.forEach { targetIndex in
            var selectedEngine = engine
            if servicePreferences.preferGoogleTranslationEngine && engine == .auto {
                selectedEngine = .google
            }
            getTranslation(translationIndex: index!, from: sourceLanguage, for: targetIndex, engine: selectedEngine)
            
        }
    }
    
    func clearTranslation(at translationID: Int) {
        translations[translationID].translation = ""
    }
    
    func translateAll(engine: PolyglotTranslatorEngine = .auto) {
        var selectedEngine = engine
        if servicePreferences.preferGoogleTranslationEngine && engine == .auto {
            selectedEngine = .google
        }
        
        var sourceLanguage = translations.first { tr in
            tr.target == .English && !tr.translation.isEmpty
        }
        if sourceLanguage == nil {
            sourceLanguage = translations.first { tr in
                !tr.translation.isEmpty
            }
        }
        
        if let sourceLanguageTarget = sourceLanguage?.target {
            getTranslation(from: sourceLanguageTarget, engine: selectedEngine)
        }
    }
    
    func deleteCard(onFinished: @escaping () -> Void) {
        cardsService.deleteCard(
            card: card,
            onFinished: onFinished
        )
    }
    
    func saveCard(onFinished: @escaping () -> Void) {
        cardsService.saveCard(
            selectedImageData: selectedImageData,
            card: card,
            translations: translations,
            decks: decks,
            onFinished: onFinished
        )
    }
    
    func speak(at translationID: Int, engine: SpeechEngine = .auto) {
        var selectedEngine = engine
        if servicePreferences.preferGoogleTTSEngine && engine == .auto {
            selectedEngine = .googleTTS
        }
        
        let translation = translations[translationID].translation
        let language = translations[translationID].target
        
        speechSynth.speak(
            string: translation,
            language: language.code,
            engine: selectedEngine,
            sessionID: "tr-\(translationID)"
        )
    }
}
