//
//  ContentView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 14.11.21.
//

import SwiftUI
import CoreData
import Combine


class ViewModel: ObservableObject {
    @Published var updateView: UUID = .init()
    
    fileprivate var disposables = Set<AnyCancellable>()
    let didUpdate = NotificationCenter.default.publisher(
        for: NSNotification.Name(
        rawValue: "NSPersistentStoreRemoteChangeNotification")
    )
    
    
    init() {
        
        didUpdate.sink {  _ in
            DispatchQueue.main.async {
                self.updateView = UUID()
            }
        }
        .store(in: &disposables)
    }
    
}

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel = .init()
    
    @Namespace var routerNamespace
    @EnvironmentObject var tabRouter: TabRouter
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if tabRouter.currentTab == .decks {
                    DecksGridScreen(
                        routerNamespace: routerNamespace
                    )
                }
                else if tabRouter.currentTab == .cards {
                    CardsListScreen(
                        deck: tabRouter.selectedDeck,
                        routerNamespace: routerNamespace
                    )
                }
                else if tabRouter.currentTab == .play {
                    GamesScreen()
                }
                else if tabRouter.currentTab == .settings {
                    SettingsScreen()
                }
            }
            
            VStack {
                Spacer()
                HStack(spacing: 40) {
                    TabBarIcon(
                        systemIconName: "cards-icon",
                        tabName: NSLocalizedString("Cards", comment: "Cards"),
                        isActive: [Page.decks, Page.cards].contains(tabRouter.currentTab),
                        showTitle: false
                    )
                        .onTapGesture {
                            withAnimation {
                                tabRouter.currentTab = .decks
                            }
                        }
                    TabBarIcon(
                        systemIconName: "play-icon",
                        tabName: NSLocalizedString("Play", comment: "Play"),
                        isActive: tabRouter.currentTab == .play,
                        showTitle: false
                    )
                        .onTapGesture {
                            withAnimation {
                                tabRouter.currentTab = .play
                            }
                        }
                    TabBarIcon(
                        systemIconName: "settings-icon",
                        tabName: NSLocalizedString("Settings", comment: "Settings"),
                        isActive: tabRouter.currentTab == .settings,
                        showTitle: false
                    )
                        .onTapGesture {
                            withAnimation {
                                tabRouter.currentTab = .settings
                            }
                        }
                }
                .frame(height: 50)
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                .background(
                    Color("TabBarColor")
                        .opacity(0.9)
                        .blur(radius: 2)
                )
                .cornerRadius(30)
            }
            .offset(y: tabRouter.isModal ? 400 : 0)
            .animation(.spring(), value: tabRouter.isModal)
        }
    }
}
