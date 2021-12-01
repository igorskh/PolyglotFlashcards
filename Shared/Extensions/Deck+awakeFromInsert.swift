//
//  Deck+awakeFromInsert.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 01.12.21.
//

import Foundation

extension Deck {
    public override func awakeFromInsert() {
        setPrimitiveValue(NSDate(), forKey: "createdAt")
    }
    
    public override func willSave() {
        if let updatedAt = updatedAt {
            if updatedAt.timeIntervalSince(Date()) > 10.0 {
                self.updatedAt = Date()
            }
            
        } else {
            self.updatedAt = Date()
        }
    }
}
