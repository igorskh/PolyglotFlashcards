//
//  DismissibleTextEditor.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 02.02.22.
//

import SwiftUI

class UITextViewWithLanguage: UITextView, UITextViewDelegate {
    var preferredLanguage: String? = nil
    var customTag: Int
    
    override var keyCommands: [UIKeyCommand]? {
        [
            UIKeyCommand(input: "\t", modifierFlags: [], action: #selector(doNextResponder))
        ]
    }
    
    @objc private func doNextResponder() {
        if let nextTextField = self.window?.viewWithTag(customTag+1) {
            nextTextField.becomeFirstResponder()
        } else {
            self.resignFirstResponder()
        }
    }

    
    init(customTag: Int, preferredLanguage: String? = nil) {
        self.preferredLanguage = preferredLanguage
        self.customTag = customTag
        super.init(frame: CGRect.zero, textContainer: nil)
        self.delegate = self
        self.tag = customTag
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
    var tag: Int
    var preferredLanguage: String? = nil

    func makeUIView(context: Context) -> UITextView {
        let view = UITextViewWithLanguage(customTag: tag, preferredLanguage: preferredLanguage)
//        view.isScrollEnabled = true
        view.isEditable = true
        view.isUserInteractionEnabled = true
//        view.textAlignment = .center
        view.font = UIFont(name: "Times New Roman", size: 18)
        view.delegate = context.coordinator
//        print(nextTag)
//        view.tag = nextTag
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
    
    var tag: Int
    var preferredLanguage: String? = nil
    var onSubmit: ((String) -> Void)?
    
    init(text: Binding<String>, tag: Int, preferredLanguage: String? = nil, onSubmit: ((String) -> Void)? = nil) {
        _text = text
        self.preferredLanguage = preferredLanguage
        editorText = text.wrappedValue
        self.tag = tag
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        MultilineTextView(text: $editorText, tag: tag, preferredLanguage: preferredLanguage)
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
