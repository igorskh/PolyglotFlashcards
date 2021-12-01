//
//  WebImage.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 29.11.21.
//

import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    @Published var data: Data = .init()

    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}

struct WebImage: View {
    @ObservedObject var imageLoader: ImageLoader
    @State var image: UIImage = UIImage()

    init(withURL url:String) {
        imageLoader = ImageLoader(urlString: url)
    }
    
    var body: some View {
        ZStack {
            if imageLoader.data.count == 0 {
                ProgressView()
            }
            Image(image: image)
                .resizable()
                .onChange(of: imageLoader.data) { data in
                    self.image = UIImage(data: data) ?? UIImage()
                }
        }
    }
}
