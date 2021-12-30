//
//  PolyglotFlashcardsApp.swift
//  Shared
//
//  Created by Igor Kim on 17.10.21.
//

import SwiftUI

@main
struct PolyglotFlashcardsApp: App {
    @Preference(\.firstLaunch) var firstLaunch
    @ObservedObject var tabRouter: TabRouter = .init()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            if firstLaunch {
                OnboardingScreen()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                ContentView()
                    .environmentObject(tabRouter)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
//
