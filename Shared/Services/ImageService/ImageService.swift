//
//  ImageService.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import Foundation

struct RemoteImage: Codable, Identifiable {
    var id: UUID = .init()
    var url: URL
}

protocol ImageService {
    func Search(q: String, onResponse: @escaping (Result<[RemoteImage]?, Error>) -> Void)
}
