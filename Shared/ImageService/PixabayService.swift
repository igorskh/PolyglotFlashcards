//
//  PixabayService.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import Foundation

struct PixabayServiceHit: Identifiable, Codable {
    var id: Int
    var pageURL: String
    var type: String
    var tags: String
    var previewURL: String
    var previewWidth: Int
    var previewHeight: Int
    var webformatURL: String
    var largeImageURL: String
}

struct PixabayServiceResponse: Codable {
    var total: Int
    var totalHits: Int
    var hits: [PixabayServiceHit]
}

class PixabayService: ImageService {
    static var apiKey: String = Configuration.value(for: "PIXABAY_TOKEN") ?? ""
    static var baseURL = "https://pixabay.com/api"
    
    static let shared = PixabayService()
    
    func Search(q: String, language: Language?, onResponse: @escaping (Result<[RemoteImage]?, Error>) -> Void) {
        var url = URLComponents(string: "\(PixabayService.baseURL)/")!
        url.queryItems = [
            URLQueryItem(name: "key", value: PixabayService.apiKey),
            URLQueryItem(name: "q", value: q),
            URLQueryItem(name: "safesearch", value: "true")
        ]
        
        let request = URLRequest(url: url.url!)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                return onResponse(.failure(error))
            }
            guard let data = data else {
                return onResponse(.success(nil))
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            guard let decoded = try? decoder.decode(PixabayServiceResponse.self, from: data) else {
                return onResponse(.success(nil))
            }
            
            let images = decoded.hits.map { im in
                RemoteImage(
                    url: URL(string: im.largeImageURL)!
                )
            }
            onResponse(.success(images))
        }.resume()
    }
    
}
