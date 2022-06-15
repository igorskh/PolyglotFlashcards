//
//  CardDetailHeaderView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 10.06.22.
//

import SwiftUI

struct CardDetailHeaderView: View {
    @EnvironmentObject var viewModel: CardDetailViewModel

    var onShare: () -> Void
    var onClose: () -> Void
    var onClear: () -> Void
    
    func onImageChanged(img: UIImage?) {
        if let imgData = img?.pngData() {
            viewModel.setImage(from: imgData)
        } else {
            viewModel.resetImage()
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            CardImagePicker(height: 200, initialImageData: viewModel.selectedImageData, onImageChanged: onImageChanged, onImageCleared: onClear)
                .clipped()
                .offset(y: viewModel.isHeaderHidden ? -250 : 0)
                .padding(.top, viewModel.isHeaderHidden ? -250 : 0)
            
            HStack {
                Text(viewModel.card != nil
                     ? LocalizedStringKey("Edit Card")
                     : LocalizedStringKey("New Card")
                )
                    .font(.title)
                    .foregroundColor(.white)
                
                Spacer()
                
                if viewModel.card != nil {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .opacity(0.7)
                        .font(.title)
                        .onTapGesture {
                            onShare()
                        }
                }
                
                Image(systemName: "xmark.circle.fill")
                    .opacity(0.7)
                    .font(.title)
                    .onTapGesture {
                        onClose()
                    }
            }
            .padding(.vertical)
            .padding(.horizontal)
            .foregroundColor(Color.white)
            .background(
                Color.black.opacity(0.5)
            )
        }
    }
}
