//
//  NSPersistentCloudKitContainer.EventType+description.swift
//  PolyglotFlashcards (iOS)
//
//  Created by Igor Kim on 05.12.21.
//

import CoreData

extension NSPersistentCloudKitContainer.EventType {
    var description: String {
        switch self {
        case .setup:
            return "Setup"
        case .import:
            return "Import"
        case .export:
            return "Export"
        @unknown default:
            return "Unknown"
        }
    }
}
