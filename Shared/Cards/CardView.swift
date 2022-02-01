//
//  CardView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import SwiftUI

struct CardView: View {
    @Preference(\.servicePreferences) var servicePreferences
    private let speechSynth: SpeechSynthesizer = .init(avSessionCategory: .ambient)
    
    var word: Card
    var translations: [Translation]
    var visibleLanguages: [Language]
    var namespace: Namespace.ID
    var show: Bool
    var isLoading: Bool
    var enableAudio: Bool
    var alignment: HorizontalAlignment
    
    func speak(translation: Translation, engine: SpeechEngine = .auto) {
        var selectedEngine = engine
        if servicePreferences.preferGoogleTTSEngine && engine == .auto {
            selectedEngine = .googleTTS
        }
        
        let text = translation.translation
        let language = translation.target
        
        speechSynth.speak(string: text, language: language.code, engine: selectedEngine)
    }
    
    init(
        word: Card,
        languages: [Language],
        visibleLanguages: [Language],
        namespace: Namespace.ID,
        alignment: HorizontalAlignment = .trailing,
        show: Bool = false,
        enableAudio: Bool = false,
        isLoading: Bool = false
    ) {
        self.word = word
        self.translations = languages.map { lang in
            Translation(original: "", translation: "", source: .Unknown, target: .Unknown)
        }
        self.visibleLanguages = visibleLanguages
        self.namespace = namespace
        self.show = show
        self.isLoading = isLoading
        self.alignment = alignment
        self.enableAudio = enableAudio

        if let trs = word.variants?.sortedArray(using: []) as? [CardVariant] {
            trs.forEach { tr in
                let lang = Language(rawValue: tr.language_code ?? "") ?? .Unknown
                if let index = languages.firstIndex(of: lang),
                   visibleLanguages.contains(lang) {
                    self.translations[index] = Translation(original: "", translation: tr.text ?? "", source: .Unknown, target: Language(rawValue: tr.language_code ?? "") ?? .Unknown)
                }
            }
        }
        self.translations = self.translations.filter {
            $0.target != .Unknown
        }
    }
    
    var background: some View {
        ZStack {
            if let imageData = word.image,
               let uiImage = UIImage(data: imageData) {
                Image(image: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            
            Color.black
                .opacity(0.7)
            
        }
        .matchedGeometryEffect(id: show ? "\(word.id.hashValue)-title" : "", in: namespace, isSource: false)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                ForEach(translations) { tr in
                    HStack {
                        Text("\(tr.target.flag)")
                        
                        if alignment == .trailing {
                            Spacer()
                        }
                        
                        Text("\(tr.translation)")
                            .foregroundColor(Color.white)
                            .fontWeight(.bold)
                        
                        if enableAudio {
                            Button {
                                speak(translation: tr)
                            } label: {
                                Image(systemName: "speaker.wave.3")
                            }
                            .foregroundColor(.white)
                        }
                        
                        if alignment == .leading {
                            Spacer()
                        }
                    }
                    .matchedGeometryEffect(id: show ? "\(word.id.hashValue)-\(tr.target.code)" : "", in: namespace, isSource: false)
                    .padding(.horizontal)
                }
                
            }
            
            if isLoading {
                LoadingBackdropView()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(
            background
        )
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
        .shadow(color: Color.gray.opacity(0.15), radius: 15, x: 0, y: 0)
        .padding(10)
    }
}
