//
//  ContentView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 14.11.21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CardsListView()
                .tabItem {
                    Image(systemName: "menucard.fill")
                    Text("Card")
                }
            
            GamesScreen()
                .tabItem {
                    Image(systemName: "play.circle.fill")
                    Text("Play")
                }
            
            SettingsScreen()
                .tabItem {
                    Image(systemName: "gear.circle.fill")
                    Text("Settings")
                }
        }
    }
}
