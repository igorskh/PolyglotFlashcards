//
//  DismissibleTextEditor.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 02.02.22.
//

import SwiftUI

class UITextViewWithLanguage: UITextView {
    var preferredLanguage: String? = nil
    
    init(preferredLanguage: String? = nil) {
        self.preferredLanguage = preferredLanguage
        super.init(frame: CGRect.zero, textContainer: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var textInputMode: UITextInputMode?
    {
        if let preferredLanguage = preferredLanguage {
            return UITextInputMode.activeInputModes.first(where: { mode in
                if let lang = mode.primaryLanguage {
                    return lang.split(separator: "-")[0].lowercased() == preferredLanguage.lowercased()
                }
                return false
            })
        }
       return super.textInputMode
    }
}

struct MultilineTextView: UIViewRepresentable {
    @Binding var text: String
    var preferredLanguage: String? = nil

    func makeUIView(context: Context) -> UITextView {
        let view = UITextViewWithLanguage(preferredLanguage: preferredLanguage)
//        view.isScrollEnabled = true
        view.isEditable = true
        view.isUserInteractionEnabled = true
//        view.textAlignment = .center
        view.font = UIFont(name: "Times New Roman", size: 18)
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> MultilineTextView.Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var control: MultilineTextView

        init(_ control: MultilineTextView) {
            self.control = control
        }

        func textViewDidChange(_ textView: UITextView) {
            control.text = textView.text
        }
    }
}

struct DismissibleTextEditor: View {
    @Binding var text: String
    
    @State private var editorText: String
    
    var preferredLanguage: String? = nil
    var onSubmit: ((String) -> Void)?
    
    init(text: Binding<String>, preferredLanguage: String? = nil, onSubmit: ((String) -> Void)? = nil) {
        _text = text
        self.preferredLanguage = preferredLanguage
        editorText = text.wrappedValue
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        MultilineTextView(text: $editorText, preferredLanguage: preferredLanguage)
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
