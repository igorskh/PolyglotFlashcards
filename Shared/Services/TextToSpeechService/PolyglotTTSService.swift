//
//  PolyglotTTSService.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 30.12.21.
//

import Foundation

struct PolyglotTTSRequest: Codable {
    var text: String
    var language: String
}

class PolyglotTTSService: TextToSpeechService {
    static var baseURL = "https://polyglot-api.cloud.beagile.one"
    
    static let shared = PolyglotTTSService()
    
    func Generate(
        text: String,
        language: String,
        onResponse: @escaping (Result<Data?, Error>) -> Void
    ) -> Void {
        let url = URL(string: "\(PolyglotTranslator.baseURL)/tts")!
        var request = URLRequest(url: url)
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        var httpBody: Data
        do {
            let ttsReq = PolyglotTTSRequest(text: text, language: language)
            httpBody = try encoder.encode(ttsReq)
        } catch {
            return onResponse(.failure(error))
        }
        
        request.httpMethod = "post"
        request.httpBody = httpBody
        
        let urlSession = URLSession(
            configuration: .default,
            delegate: URLSessionPinningDelegate(forResource: "polyglot-api"),
            delegateQueue: .main
        )
        
        urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                return onResponse(.failure(error))
            }
            
            guard let data = data else {
                return onResponse(.success(nil))
            }
            onResponse(.success(data))
        }.resume()
    }
}
