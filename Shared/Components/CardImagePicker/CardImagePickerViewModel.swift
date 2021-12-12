//
//  CardImagePickerViewModel.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 12.12.21.
//

import SwiftUI

class CardImagePickerViewModel: ObservableObject {
    @Published var images: [RemoteImage]?
    @Published var selectedImageID = -1
    @Published var error: Error?
    
    private var imageSearch: ImageService = PixabayService.shared
    
    func getImages(query: String) {
        error = nil
        imageSearch.Search(q: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let images):
                    if let images = images, images.count > 0 {
                        self.selectedImageID = 0
                    } else {
                        self.selectedImageID = -1
                    }
                    self.images = images
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }
}
