//
//  TabRouter.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 29.11.21.
//

import SwiftUI
import CoreData

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
    @Published var selectedCard: Card? = nil
    @Published var addNewCard: Bool = false
    
    func redirectFromWidgetURL(url: URL) {
        let urlString = url.absoluteString
        let viewContext = PersistenceController.shared.container.viewContext
        
        self.addNewCard = false
        if urlString.hasPrefix("widget://card") {
            let urlSuffix = String(urlString.suffix(urlString.count - 14))
            let objectURL = URL(string: urlSuffix)!
            
            let objectID = viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: objectURL)
            let card = viewContext.object(with: objectID!) as? Card
            
            self.selectedCard = card
            self.selectedDeck = card?.decks?.sortedArray(using: []).first as? Deck
            
            self.currentTab = .cards
        } else if urlString.hasPrefix("widget://newCard") {
            self.addNewCard = true
            self.selectedCard = nil
            self.selectedDeck = nil
            self.currentTab = .cards
        }
    }
}
