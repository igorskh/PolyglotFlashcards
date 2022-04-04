//
//  DecksGridView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 02.12.21.
//

import SwiftUI
import Combine

class DecksGridScreenViewModel: ObservableObject {
    @Published var decks: [Deck] = []
    
    private var viewContext = PersistenceController.shared.container.viewContext
    
    init() {
        fetchDecks()
    }
    
    func fetchDecks(_ searchText: String? = nil) {
        decks = CardsService.shared.getDecks(searchText: searchText)
    }
}

struct DecksGridScreen: View {
    @EnvironmentObject var tabRouter: TabRouter
    
    @ObservedObject var viewModel: DecksGridScreenViewModel = .init()
    
    @State var showAddDecks: Bool = false
    @State var selectedDeck: Deck? {
        didSet {
            tabRouter.isModal = selectedDeck != nil
        }
    }
    @State var scaleDeckView: Deck?
    @State var showSearch: Bool = false {
        didSet {
            tabRouter.isModal = showSearch
        }
    }
    @State private var showImporter = false
    @State private var importText: String?
    
    @Namespace var namespace
    var routerNamespace: Namespace.ID
    
    func openDeck(_ item: Deck?) {
        withAnimation(.spring()) {
            selectedDeck = item
        }
    }
    
    var body: some View {
        ZStack {
            ZStack {
                DecksGridView(
                    selectedDeck: $selectedDeck,
                    decks: viewModel.decks,
                    namespace: namespace,
                    openDeck: openDeck
                )
                
                VStack {
                    HStack {
                        Text(LocalizedStringKey("Polyglot Cards"))
                            .matchedGeometryEffect(id: "router-title", in: routerNamespace)
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                tabRouter.isModal = true
                                if showImporter {
                                    showImporter = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showImporter.toggle()
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.down.circle.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button {
                            withAnimation {
                                showSearch.toggle()
                            }
                        } label: {
                            Image(systemName: "magnifyingglass.circle.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            showAddDecks.toggle()
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .font(.title)
                    .padding()
                    .background(
                        VisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
                            .edgesIgnoringSafeArea(.all)
                    )
                    .sheet(isPresented: $showAddDecks, onDismiss: {
                        viewModel.fetchDecks()
                    }) {
                        DecksListView(selectedDecks: .constant([]), canEdit: true, canSelect: false)
                    }
                    
                    Spacer()
                }
            }
            
            if showSearch {
                SearchScreen(isPresented: $showSearch, routerNamespace: routerNamespace)
                    .transition(.move(edge: .bottom))
            }
            
            if importText != nil {
                CardsImportView(inputText: $importText)
            }
            
            if let deck = selectedDeck {
                VisualEffectView(effect: UIBlurEffect(style: .dark))
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        openDeck(nil)
                    }
                    
                DeckDetailView(deck: deck, namespace: namespace) {
                    withAnimation(.spring()) {
                        selectedDeck = nil
                    }
                }
                .frame(maxWidth: 600, maxHeight: 800)
                
            }
        }
        .onChange(of: importText) { value in
            if value == nil {
                tabRouter.isModal = false
            }
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.plainText, .commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile: URL = try result.get().first else { return }
                guard selectedFile.startAccessingSecurityScopedResource() else { return }
                
                guard let message = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                
                importText = message
            } catch {
                print(error.localizedDescription)
                importText = nil
            }
        }
    }
}
