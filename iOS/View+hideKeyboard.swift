//
//  View+hideKeyboard.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 10.01.22.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}
