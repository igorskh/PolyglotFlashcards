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
    @ObservedObject var appLogger: AppLogger = .shared
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            if firstLaunch {
                OnboardingScreen()
            } else {
                ContentView()
                    .alert(isPresented: $appLogger.showAlert) {
                        Alert(
                            title: Text("Error"),
                            message: Text(appLogger.history.last ?? "N/A")
                        )
                    }
                    .environmentObject(tabRouter)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .onOpenURL { url in
                        tabRouter.redirectFromWidgetURL(url: url)
                    }
            }
        }
    }
}
