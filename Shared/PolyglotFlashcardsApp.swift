//
//  PolyglotFlashcardsApp.swift
//  Shared
//
//  Created by Igor Kim on 17.10.21.
//

import SwiftUI

@main
struct PolyglotFlashcardsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
