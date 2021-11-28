//
//  CardView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import SwiftUI

struct CardView: View {
    var word: Card
    var translations: [Translation]
    var visibleLanguages: [Language]
    var namespace: Namespace.ID
    var show: Bool
    
    init(word: Card, languages: [Language], visibleLanguages: [Language], namespace: Namespace.ID, show: Bool) {
        self.word = word
        self.translations = languages.map { lang in
            Translation(original: "", translation: "", source: .Unknown, target: .Unknown)
        }
        self.visibleLanguages = visibleLanguages
        self.namespace = namespace
        self.show = show

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
                    .clipped()
                
            }
            
            Color.black
                .opacity(0.7)
            
        }
        .matchedGeometryEffect(id: show ? "\(word.id.hashValue)-title" : "", in: namespace, isSource: false)
    }
    
    var body: some View {
        VStack {
            ForEach(translations) { tr in
                HStack {
                    Text("\(tr.target.flag)")
                    Spacer()
                    Text("\(tr.translation)")
                        .foregroundColor(Color.white)
                        .fontWeight(.bold)
                    
                }
                .matchedGeometryEffect(id: show ? "\(word.id.hashValue)-\(tr.target.code)" : "", in: namespace, isSource: false)
                .padding(.horizontal)
            }
            
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(
            background
        )
        .clipped()
        .clipShape(Rectangle())
        .contentShape(Rectangle())
        .shadow(color: Color.gray.opacity(0.15), radius: 15, x: 0, y: 0)
        .padding(10)
    }
}
