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

    func copy(size: NSSize) -> NSImage? {
        let frame = NSMakeRect(0, 0, size.width, size.height)
        
        guard let rep = self.bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }
        
        let img = NSImage(size: size)
        
        img.lockFocus()
        defer { img.unlockFocus() }
        
        if rep.draw(in: frame) {
            return img
        }
        
        return nil
    }
    
    convenience init?(uiImage name: String) {
        self.init(named: Name(name))
    }
    
    
    func pngData() -> Data? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else { return nil }
        let imageRep = NSBitmapImageRep(cgImage: cgImage)
        imageRep.size = self.size
        return imageRep.representation(using: .png, properties: [:])
    }
    
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        let newSize: NSSize
        
        let widthRatio  = size.width / self.size.width
        let heightRatio = size.height / self.size.height
        
        if widthRatio > heightRatio {
            newSize = NSSize(width: floor(self.size.width * widthRatio), height: floor(self.size.height * widthRatio))
        } else {
            newSize = NSSize(width: floor(self.size.width * heightRatio), height: floor(self.size.height * heightRatio))
        }
        
        return self.copy(size: newSize)!
    }
}
