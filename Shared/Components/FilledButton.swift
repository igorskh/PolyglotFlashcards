//
//  FilledButton.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 28.11.21.
//

import SwiftUI

struct FilledButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.heavy)
        }
            .foregroundColor(.white)
            .padding(10)
            .background(color)
            .cornerRadius(8)
    }
}
