//
//  Card+UIImage.swift
//  PolyglotFlashcards (iOS)
//
//  Created by Igor Kim on 28.11.21.
//

import Foundation
import SwiftUI

extension Card {
    var uiImage: UIImage? {
        if let imageData = self.image,
           let uiImage = UIImage(data: imageData) {
            return uiImage
        }
        return nil
    }
}
