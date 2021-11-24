//
//  DeepLTranslator.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import Foundation

struct DeepLTranslation: Codable {
    var detectedSourceLanguage: String
    var text: String
}

struct DeepLTranslationResponse: Codable {
    var translations: [DeepLTranslation]
}

struct DeepLTranslationRequest: Codable {
    var text: String
    var sourceLang: String?
    var targetLang: String
    
    var asUrlComponents: Data {
        var requestComponents = URLComponents()
        requestComponents.queryItems = [
            URLQueryItem(name: "source_lang", value: sourceLang?.uppercased()),
            URLQueryItem(name: "target_lang", value: targetLang.uppercased()),
            URLQueryItem(name: "text", value: text)
        ]
        return requestComponents.query!.data(using: .utf8)!
    }
}

class DeepLTranslator: TranslationService {
    static var apiKey = Configuration.value(for: "DEEPL_TOKEN") ?? ""
    static var baseURL = "https://api-free.deepl.com/v2"
    
    static let shared = DeepLTranslator()
    
    func Translate(text: String, source: Language?, target: Language, onResponse: @escaping (Result<[Translation]?, Error>) -> Void)  {
        let url = URL(string: "\(DeepLTranslator.baseURL)/translate")!
        var request = URLRequest(url: url)
        request.addValue("DeepL-Auth-Key \(DeepLTranslator.apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "post"
        request.httpBody = DeepLTranslationRequest(text: text, sourceLang: source?.code, targetLang: target.code).asUrlComponents
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                return onResponse(.failure(error))
            }
            guard let data = data else {
                return onResponse(.success(nil))
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        
            guard let decoded = try? decoder.decode(DeepLTranslationResponse.self, from: data) else {
                return onResponse(.success(nil))
            }
            let translations = decoded.translations.map { tr in
                Translation(
                    original: text,
                    translation: tr.text,
                    source: Language(rawValue: tr.detectedSourceLanguage.lowercased()) ?? .Unknown,
                    target: target
                )
            }
            onResponse(.success(translations))
        }.resume()
    }
}

