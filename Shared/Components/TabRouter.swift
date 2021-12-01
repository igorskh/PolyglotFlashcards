//
//  TabRouter.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 29.11.21.
//

import SwiftUI

enum Page {
    case cards
    case play
    case settings
}

struct TabBarIcon: View {
    let systemIconName, tabName: String
    let isActive: Bool
    
    var body: some View {
        VStack {
            Image(systemIconName)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(5)
            
            Text(tabName)
                .font(.footnote)
            Spacer()
        }
        .padding(.top, 5)
        .foregroundColor(isActive ? .accentColor : .primary)
    }
}

class TabRouter: ObservableObject {
    @Published var isModal: Bool = false
    @Published var currentTab: Page = .cards
}
