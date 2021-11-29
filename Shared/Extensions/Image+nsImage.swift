//
//  Image+nsImage.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 28.11.21.
//

import SwiftUI

extension Image {
    init(image: UIImage) {
#if os(iOS) || os(watchOS) || os(tvOS)
        self.init(uiImage: image)
#elseif os(macOS)
        self.init(nsImage: image)
#endif
    }
}
