//
//  CardImagesView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 02.12.21.
//

import SwiftUI

struct CardImagesView: View {
    var title: String
    var card: Card?
    
    var background: some View {
        ZStack {
            if let imageData = card?.image,
               let uiImage = UIImage(data: imageData) {
                Image(image: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                Image("question")
            }
            
            Color.black
                .opacity(0.7)
            
        }
    }
    
    var body: some View {
        VStack {
            Text(title)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(
            background
        )
        .clipped()
        .clipShape(Rectangle())
        .contentShape(Rectangle())
        .padding(10)
    }
    
}
