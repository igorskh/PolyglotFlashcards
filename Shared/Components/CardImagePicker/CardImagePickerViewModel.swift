//
//  CardImagePickerViewModel.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 12.12.21.
//

import SwiftUI


class CardImagePickerViewModel: ObservableObject {
    @Published var images: [RemoteImage]?
    @Published var selectedImageID = -1 {
        didSet {
            if let images = images,
               selectedImageID > -1,
               selectedImageID < images.count  {
                URLSession.shared.dataTask(with: images[selectedImageID].url) { data, _, _ in
                    if let data = data,
                       let uiImage = UIImage(data: data) {
                        self.onNewImageSelected(uiImage)
                    }
                }.resume()
            }
        }
    }
    @Published var error: Error?
    @Published var showInitialImage: Bool = true
    @Published var searchRequest: String = ""
    @Published var uiImage: UIImage = UIImage() {
        didSet {
            onNewImageSelected(uiImage)
        }
    }
    @Published var selectedImage: UIImage? = nil
    
    private var imageSearch: ImageService = PixabayService.shared

    func onNewImageSelected(_ image: UIImage) {
        DispatchQueue.main.async {
            self.showInitialImage = false
            self.selectedImage = image
        }
    }
    
    func resetImage() {
        selectedImage = nil
        uiImage = UIImage()
    }
    
    func getImages() {
        error = nil
        imageSearch.Search(q: searchRequest) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let images):
                    self.images = images
                    if let images = images, images.count > 0 {
                        self.selectedImageID = 0
                    } else {
                        self.selectedImageID = -1
                    }
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }
}
