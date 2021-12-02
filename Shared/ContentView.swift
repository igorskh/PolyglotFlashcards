//
//  ContentView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 14.11.21.
//

import SwiftUI

struct ContentView: View {
    @Namespace var routerNamespace
    @EnvironmentObject var tabRouter: TabRouter
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if tabRouter.currentTab == .decks {
                    DecksGridScreen(routerNamespace: routerNamespace)
                }
                else if tabRouter.currentTab == .cards {
                    CardsListScreen(deck: tabRouter.selectedDeck, routerNamespace: routerNamespace)
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
                HStack(spacing: 50) {
                    TabBarIcon(
                        systemIconName: "cards-icon",
                        tabName: "Cards",
                        isActive: [Page.decks, Page.cards].contains(tabRouter.currentTab)
                    )
                        .onTapGesture {
                            withAnimation {
                                tabRouter.currentTab = .decks
                            }
                        }
                    TabBarIcon(
                        systemIconName: "play-icon",
                        tabName: "Play",
                        isActive: tabRouter.currentTab == .play
                    )
                        .onTapGesture {
                            withAnimation {
                                tabRouter.currentTab = .play
                            }
                        }
                    TabBarIcon(
                        systemIconName: "settings-icon",
                        tabName: "Settings",
                        isActive: tabRouter.currentTab == .settings
                    )
                        .onTapGesture {
                            withAnimation {
                                tabRouter.currentTab = .settings
                            }
                        }
                }
                .frame(height: 70)
                .padding(.horizontal, 20)
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
