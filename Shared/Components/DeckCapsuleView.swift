//
//  DeckCapsuleView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 01.12.21.
//

import SwiftUI

struct DeckCapsuleView: View {
    var title: String
    var onDelete: (() -> Void)?
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            
            if let onDelete = onDelete {
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(5)
        .background(
            Color.blue
                .cornerRadius(10)
        )
    }
}
