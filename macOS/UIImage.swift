//
//  UIImage.swift
//  PolyglotFlashcards (macOS)
//
//  Created by Igor Kim on 28.11.21.
//

import Cocoa

typealias UIImage = NSImage

extension NSImage {
    var cgImage: CGImage? {
        var proposedRect = CGRect(origin: .zero, size: size)

        return cgImage(forProposedRect: &proposedRect,
                       context: nil,
                       hints: nil)
    }

    convenience init?(uiImage name: String) {
        self.init(named: Name(name))
    }
    
    func pngData() -> Data? {
        let imageRep = NSBitmapImageRep(data: self.tiffRepresentation!)
        let pngData = imageRep?.representation(using: .png, properties: [:])
        return pngData
    }
    
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        let newImage = NSImage(size: scaledImageSize)
        newImage.lockFocus()
        self.draw(in: NSMakeRect(0, 0, scaledImageSize.width, scaledImageSize.height), from: NSMakeRect(0, 0, self.size.width, self.size.height), operation: NSCompositingOperation.clear, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = scaledImageSize
        return NSImage(data: newImage.tiffRepresentation!)!
    }
}

struct User {
    let name: String
    let profileImage: UIImage
}
