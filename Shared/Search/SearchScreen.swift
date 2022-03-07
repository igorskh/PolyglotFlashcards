//
//  SearchScreen.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 09.02.22.
//

import SwiftUI
import Introspect

struct SearchView: View {
    @EnvironmentObject var tabRouter: TabRouter
    
    @ObservedObject var viewModel: SearchScreenViewModel = .init()
    
    @Namespace var namespace
    var routerNamespace: Namespace.ID
    
    var onClose: () -> Void
    
    var body: some View {
        ZStack {
            if viewModel.searchMode == .decks {
                DecksGridView(
                    selectedDeck: .constant(nil),
                    decks: viewModel.decks,
                    namespace: namespace,
                    showNoCategory: false,
                    topPadding: 100,
                    bottomPadding: 0
                )
            } else {
                VariantsListView(
                    variants: viewModel.variants,
                    topPadding: 100,
                    bottomPadding: 0
                )
            }

            VStack {
                VStack {
                    HStack {
                        TextField(viewModel.searchMode == .decks ? "Search deck" : "Search card", text: $viewModel.searchText)
                            .textFieldStyle(.roundedBorder)
                            .introspectTextField { textField in
                                textField.becomeFirstResponder()
                            }
                        
                        Button {
                            onClose()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .font(.title)
                        .foregroundColor(.primary)
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Picker("Search mode", selection: $viewModel.searchMode) {
                        Text("Cards")
                            .tag(CardsSearchMode.variants)
                        Text("Decks")
                            .tag(CardsSearchMode.decks)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth: 350)
                }
                .padding()
                .background(
                    VisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
                        .edgesIgnoringSafeArea(.all)
                )
                Spacer()
            }
        }
    }
}

struct SearchScreen: View {
    @EnvironmentObject var tabRouter: TabRouter
    @Binding var isPresented: Bool
    var routerNamespace: Namespace.ID
    
    var body: some View {
        SearchView(routerNamespace: routerNamespace) {
            withAnimation {
                isPresented = false
            }
        }
        .background(
            VisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
                .edgesIgnoringSafeArea(.all)
        )
        .onDisappear {
            tabRouter.isModal = false
        }
    }
}
