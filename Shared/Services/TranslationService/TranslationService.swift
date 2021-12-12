//
//  TranslationService.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import Foundation
import NaturalLanguage
import SwiftUI

struct Translation: Identifiable {
    var original: String
    var translation: String
    var source: Language
    var target: Language
    
    var id: String {
        "\(source)_\(target)_\(translation)"
    }
    
    var attributedString: NSMutableAttributedString {
        let attributes = WordTagger.enumerate(text: translation, language: target)
        let sText = NSMutableAttributedString(string: "")

        attributes.forEach { attr in
            var a2: [NSAttributedString.Key: Any] = [:]
            
            if attr.tag == NLTag.noun {
                a2[.foregroundColor] = UIColor.black
            } else if attr.tag == NLTag.verb {
                a2[.foregroundColor] = UIColor.blue
            } else {
                a2[.foregroundColor] = UIColor.gray
            }
            
            let s2 = NSAttributedString(string: attr.text, attributes: a2)
            sText.append(s2)
        }
        
        return sText
    }
}

protocol TranslationService {
    func Translate(text: String, source: Language?, target: Language, onResponse: @escaping (Result<[Translation]?, Error>) -> Void)
}
