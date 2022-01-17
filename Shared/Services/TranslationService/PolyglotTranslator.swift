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

enum PolyglotTranslatorEngine: String, Codable {
    case auto = ""
    case google = "google"
    case deepL = "deepL"
    case yandex = "yandex"
}


class PolyglotTranslator: TranslationService {
    static var baseURL = "https://\(Configuration.value(for: "POLYGLOT_API_BASE_URL") ?? "")"
    
    static let shared = PolyglotTranslator()
    
    func Translate(text: String,
                   source: Language?,
                   target: Language,
                   options: TranslationOptions? = nil,
                   onResponse: @escaping (Result<[Translation]?, Error>) -> Void)  {
        
        var urlString = "\(PolyglotTranslator.baseURL)/translate"
        if let options = options,
            options.engine != .auto {
            urlString.append("?engine=\(options.engine.rawValue)")
        }
        
        let url = URL(string: urlString)!
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
