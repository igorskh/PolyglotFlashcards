//
//  CardsSearchView.swift
//  PolyglotFlashcards (iOS)
//
//  Created by Igor Kim on 06.02.22.
//

import SwiftUI

struct CardsSearchView: View {
    @EnvironmentObject var tabRouter: TabRouter
    
    @ObservedObject var viewModel: CardsSearchViewModel = .init()
    
    func navigateCard(from variant: CardVariant) {
        tabRouter.currentTab = .cards
        tabRouter.selectedCard = variant.card
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("Search card", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
            }.padding(.horizontal, 10)
            
            ScrollView {
                ForEach(viewModel.variants) { variant in
                    HStack {
                        Text(Language(rawValue: variant.language_code ?? "")?.flag ?? "?")
                        Text(variant.text ?? "N/A")
                        
                        Spacer()
                    }
                    .onTapGesture {
                        navigateCard(from: variant)
                    }
                    .padding(10)
                }
            }
            .background(
                Color.primary.colorInvert()
            )
        }
    }
}
