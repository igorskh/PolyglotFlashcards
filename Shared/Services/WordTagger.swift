//
//  WordTagger.swift
//  PolyglotFlashcards (iOS)
//
//  Created by Igor Kim on 25.11.21.
//

import Foundation
import NaturalLanguage

struct WordTaggerResult {
    var tag: NLTag
    var text: String
    var range: Range<String.Index>
}

class WordTagger {
    static func enumerate(text: String, language: Language) -> [WordTaggerResult] {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        let options : NLTagger.Options = []

        tagger.string = text
        let range = Range(NSRange(location: 0, length: text.count), in: text)
        tagger.setLanguage(NLLanguage(language), range: range!)
        
        var result: [WordTaggerResult] = []
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag = tag{
                result.append(WordTaggerResult(tag: tag, text: "\(text[tokenRange])", range: tokenRange))
            }
            return true
        }
        
        return result
    }
}
