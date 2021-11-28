//
//  AttributedText.swift
//  PolyglotFlashcards (macOS)
//
//  Created by Igor Kim on 28.11.21.
//

import SwiftUI

typealias UIColor = NSColor

struct AttributedText: NSViewRepresentable {
    let attributedString: NSAttributedString
    
    init(_ attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }
    
    func makeNSView(context: Context) -> NSTextField {
        let label = NSTextField()
        
        label.lineBreakMode = .byClipping
        label.maximumNumberOfLines = 1

        return label
    }
    
    func updateNSView(_ uiView: NSTextField, context: Context) {
        uiView.attributedStringValue = attributedString
    }
}
