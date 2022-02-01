//
//  DismissibleTextEditor.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 02.02.22.
//

import SwiftUI

struct DismissibleTextEditor: View {
    @Binding var text: String
    
    @State private var editorText: String
    
    var onSubmit: ((String) -> Void)?
    
    init(text: Binding<String>, onSubmit: ((String) -> Void)? = nil) {
        _text = text
        editorText = text.wrappedValue
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        TextEditor(text: $editorText)
            .onChange(of: editorText) { value in
                if editorText.contains("\n") {
                    editorText = editorText.replacingOccurrences(of: "\n", with: "")
                    onSubmit?(editorText)
                    hideKeyboard()
                } else {
                    text = editorText
                }
            }
            .onChange(of: text) { value in
                if value != editorText {
                    editorText = value
                }
            }
    }
}
