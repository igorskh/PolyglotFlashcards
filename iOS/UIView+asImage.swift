//
//  UIView+asImage.swift
//  PolyglotFlashcards (iOS)
//
//  Created by Igor Kim on 16.01.22.
//

import SwiftUI

extension UIView {
    func asImage() -> UIImage {
        let newBounds =  CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: bounds.height-45)
        let renderer = UIGraphicsImageRenderer(bounds: newBounds)
        return renderer.image { rendererContext in
// [!!] Uncomment to clip resulting image
//            rendererContext.cgContext.addPath(
//                UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath)
//            rendererContext.cgContext.clip()
           
            rendererContext.cgContext.clip(to: newBounds)

// As commented by @MaxIsom below in some cases might be needed
// to make this asynchronously, so uncomment below DispatchQueue
// if you'd same met crash
//            DispatchQueue.main.async {
                 layer.render(in: rendererContext.cgContext)
//            }
        }
    }
}
