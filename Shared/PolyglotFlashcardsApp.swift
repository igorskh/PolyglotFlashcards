//
//  PolyglotFlashcardsApp.swift
//  Shared
//
//  Created by Igor Kim on 17.10.21.
//

import SwiftUI

@main
struct PolyglotFlashcardsApp: App {
    @ObservedObject var tabRouter: TabRouter = .init()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tabRouter)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
