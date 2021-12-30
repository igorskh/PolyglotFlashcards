//
//  PolyglotTranslator.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 29.12.21.
//

import Foundation

struct PolyglotTranslationRequest: Codable {
    var text: String
    var source: String?
    var target: String
    var formality: String? = nil
}

struct PolyglotTranslationResponse: Codable {
    var text: String
    var translation: String
    var source: String
    var target: String
}


class PolyglotTranslator: TranslationService {
    static var baseURL = "http://localhost:1323"
    
    static let shared = PolyglotTranslator()
    
    func Translate(text: String,
                   source: Language?,
                   target: Language,
                   options: TranslationOptions? = nil,
                   onResponse: @escaping (Result<[Translation]?, Error>) -> Void)  {
        let url = URL(string: "\(PolyglotTranslator.baseURL)/translate")!
        var request = URLRequest(url: url)
        
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        var httpBody: Data
        do {
            var trReq = PolyglotTranslationRequest(
                    text: text,
                    source: source?.code,
                    target: target.code
                )
            if let options = options {
                if options.formality != .auto {
                    trReq.formality = options.formality == .informal ? "less" : "more"
                }
            
                if options.locale != "" {
                    trReq.target += "-\(options.locale)" 
                }
            }
            httpBody = try encoder.encode(trReq)
        } catch {
            return onResponse(.failure(error))
        }
        
        request.httpMethod = "post"
        request.httpBody = httpBody
        
        let urlSession = URLSession(
            configuration: .default,
            delegate: .none,
            delegateQueue: .main
        )
        
        urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                return onResponse(.failure(error))
            }
            
            guard let data = data else {
                return onResponse(.success(nil))
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        
            guard let decoded = try? decoder.decode(PolyglotTranslationResponse.self, from: data) else {
                return onResponse(.success(nil))
            }
            let translation = Translation(
                original: text,
                translation: decoded.translation,
                source: Language(rawValue: decoded.source.lowercased()) ?? .Unknown,
                target: target
            )
            
            onResponse(.success([translation]))
        }.resume()
    }
}
