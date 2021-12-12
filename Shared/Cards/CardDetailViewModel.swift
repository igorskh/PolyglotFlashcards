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
    @Published var translations: [Translation] = []
    @Published var errorMessage: String = ""
    @Published var decks: [Deck]

    @Published var nQueuedRequests: Int = 0
    
    @Published var query: String = ""
    
    private var translator: TranslationService = DeepLTranslator.shared
    private let speechSynth: SpeechSynthesizer = .init()
    private var selectedImageData: Data = .init()

    @Preference(\.languages) var languages
    
    private let lock = NSLock()
    let card: Card?
    
    init(card: Card? = nil) {
        self.card = card
        self.decks = card?.decks?.sortedArray(using: []) as? [Deck] ?? []
        
        translations =  languages.map { lang in
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
        
        translator.Translate(text: text, source: sourceLang, target: target) { result in
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
    
    func saveCard(withImage imageData: Data?, context: NSManagedObjectContext, onFinished: @escaping () -> Void) {
        var newWord: Card?
        if let card = card {
            newWord = card
        } else {
            newWord = Card(context: context)
        }
        if let imageData = imageData {
            newWord?.image = imageData
        }
        
        newWord?.languages = self.translations.reduce("|", { partialResult, tr in
            return partialResult + tr.target.code + "|"
        })
        newWord?.decks = Set<Deck>(decks) as NSSet
        
        self.translations.forEach { tr in
            var newWordTranslation: CardVariant?
            var isCreating: Bool = false
            
            newWordTranslation = newWord?.variants?.first(where: {
                ($0 as? CardVariant)?.language_code == tr.target.rawValue
            }) as? CardVariant
            
            if newWordTranslation == nil {
                newWordTranslation = CardVariant(context: context)
                isCreating = true
            }
            
            newWordTranslation!.text = tr.translation
            newWordTranslation!.language_code = tr.target.rawValue
            if isCreating {
                newWord?.addToVariants(newWordTranslation!)
            }
        }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError.code) \(nsError), \(nsError.userInfo)")
        }
        onFinished()
        
    }
    
    func deleteCard(context: NSManagedObjectContext, onFinished: @escaping () -> Void) {
        if let card = card {
            context.delete(card)
            
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            
            onFinished()
        }
    }
    
    func saveCard(context: NSManagedObjectContext, onFinished: @escaping () -> Void) {
        if selectedImageData.count > 0 {
            if let image = UIImage(data: selectedImageData)?.scalePreservingAspectRatio(targetSize: CGSize(width: 500, height: 500)),
               let data = image.pngData() {
                self.saveCard(withImage: data, context: context, onFinished: onFinished)
            }
            
        } else {
            self.saveCard(withImage: nil, context: context, onFinished: onFinished)
        }
    }
    
    func speak(at translationID: Int) {
        speechSynth.speak(string: translations[translationID].translation, language: translations[translationID].target.code)
    }
}
