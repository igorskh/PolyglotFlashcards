//
//  TabRouter.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 29.11.21.
//

import SwiftUI

enum Page {
    case decks
    case cards
    case play
    case settings
}

struct TabBarIcon: View {
    let systemIconName, tabName: String
    let isActive: Bool
    let showTitle: Bool
    
    var body: some View {
        VStack {
            Image(systemIconName)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(5)
            
            if showTitle {
                Text(tabName)
                    .font(.footnote)
                Spacer()
            }
        }
        .frame(width: 40)
        .foregroundColor(isActive ? .accentColor : .primary)
    }
}

class TabRouter: ObservableObject {
    @Published var isModal: Bool = false
    @Published var currentTab: Page = .decks
    @Published var selectedDeck: Deck? = nil
}
