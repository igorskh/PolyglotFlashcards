//
//  GameCardView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 29.11.21.
//

import SwiftUI

struct GameCardView: View {
    var variant: CardVariant
    var selectedIDs: [ObjectIdentifier]
    var correctID: ObjectIdentifier
    
    var body: some View {
        VStack {
            Text("\(variant.text ?? "N/A")")
                .fontWeight(.heavy)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60, alignment: .center)
        .background(
            selectedIDs.contains(variant.id)
            ? (correctID == variant.id ? Color.green.opacity(0.8) : Color.red)
            : Color.blue
        )
    }
}
