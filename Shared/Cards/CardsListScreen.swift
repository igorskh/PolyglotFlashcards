//
//  CardsListScreen.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import SwiftUI
import WidgetKit

enum CardOpenMode {
    case detail
    case preview
    case both
}

struct CardsListScreen: View {    
    @EnvironmentObject var tabRouter: TabRouter
    @Namespace var namespace
    
    var routerNamespace: Namespace.ID
    var deck: Deck?
    
    var cardsRequest: FetchRequest<Card>
    private var items: FetchedResults<Card>{cardsRequest.wrappedValue}
    
    @State var selectedCard: Card?
    @State var selectedPreviewCard: Card?
    @State var showShareSheet: Bool = false
    
    @State var showDetailCard: Bool = false {
        didSet {
            DispatchQueue.main.async {
                tabRouter.isModal = showDetailCard
            }
        }
    }
    @State var loadingCardID: ObjectIdentifier?
    
    @State var exportTextURL: URL?
    @State var showShareCSVSheet: Bool = false
    
    
    @Preference(\.languages) var languages
    
    @Preference(\.filteredLanguages) var storedFilteredLanguages
    @State var filteredLanguages: [Language] = []
    
    init(deck: Deck? = nil, routerNamespace: Namespace.ID) {
        self.deck = deck
        let predicate: NSPredicate = deck == nil || deck!.title == nil ?
            NSPredicate(format: "decks.@count == 0") :
            NSPredicate(format: "(ANY decks.title == %@)", deck!.title!)
        
        cardsRequest = FetchRequest(
            entity: Card.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Card.createdAt, ascending: false)],
            predicate: predicate
        )
        
        self.routerNamespace = routerNamespace
        _filteredLanguages = State(wrappedValue: storedFilteredLanguages)
    }
    
    func addCard() {
        if selectedCard != nil || showDetailCard {
            toggleCard(destination: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showAddCard()
            }
        } else {
            showAddCard()
        }
    }
    
    func shareCards() {
        var variantsLanguages: [String] = []
        var exportText = ""
        languages.forEach { lang in
            variantsLanguages.append(lang.code)
            exportText += "\(lang.code);"
        }
        exportText += "\n"
        
        items.forEach { card in
            var variantsText = variantsLanguages.map { _ in
                ""
            }
            card.variants?.forEach({ variant in
                if let v = variant as? CardVariant,
                   let langCode = v.language_code,
                   let index = variantsLanguages.firstIndex(of: langCode) {
                    variantsText[index] = v.text ?? ""
                }
            })
            
            variantsText.forEach { v in
                exportText += "\(v);"
            }
            exportText += "\n"
        }
        
        let filename = deck?.title ?? NSLocalizedString("Uncategorized", comment: "Uncategorized");
        
        let temporaryFolder = FileManager.default.temporaryDirectory
        let fileName = "\(filename).csv"
        let temporaryFileURL = temporaryFolder.appendingPathComponent(fileName)
        
        do {
            try exportText.write(to: temporaryFileURL, atomically: false, encoding: .utf8)
            
            self.exportTextURL = temporaryFileURL
            showShareCSVSheet = true
        } catch {
            print(error)
        }
        
    }
    
    func showAddCard() {
        withAnimation(.easeInOut) {
            showDetailCard = true
        }
    }
    
    func toggleCard(destination: Card? = nil, mode: CardOpenMode = .detail) {
        if destination != nil && mode == .detail {
            loadingCardID = destination?.id
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring()) {
                if mode == .detail || mode == .both {
                    showDetailCard = destination != nil
                    selectedCard = destination
                }
                if mode == .preview || mode == .both {
                    selectedPreviewCard = destination
                }
                if mode == .detail || destination == nil {
                    selectedPreviewCard = nil
                    showShareSheet = false
                }
            }
            loadingCardID = nil
        }
    }
    
    func checkRedirect() {
        if let card = tabRouter.selectedCard {
            self.toggleCard(destination: card)
            tabRouter.selectedCard = nil
        }
        if tabRouter.addNewCard {
            tabRouter.addNewCard = false
            addCard()
        }
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 300))
    ]
    
    var cardsGrid: some View {
        ScrollView {
            VStack {}.frame(height: 60)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(items) { item in
                    CardView(
                        word: item,
                        languages: languages,
                        visibleLanguages: filteredLanguages,
                        namespace: namespace,
                        show: selectedCard != nil && selectedCard!.id == item.id,
                        enableAudio: true,
                        isLoading: loadingCardID != nil && loadingCardID! == item.id
                    )
                        .contentShape(Rectangle())
                        .opacity(selectedCard != nil && selectedCard!.id == item.id ? 0.0 : 1.0)
                        .onTapGesture {
                            toggleCard(destination: item)
                        }
                        .animatedLongTap(onDismiss: {}) {
                            toggleCard(destination: item, mode: .preview)
                        }
                        .matchedGeometryEffect(
                            id: deck != nil ? "\(deck!.id)-\(item.id)" : "\(item.id)",
                            in: routerNamespace
                        )
                        .matchedGeometryEffect(
                            id: "\(item.id)-card",
                            in: namespace,
                            isSource: selectedPreviewCard != item
                        )
                }
            }
            
            Spacer()
                .padding(.bottom, 50)
        }
    }
    
    var header: some View {
        VStack {
            HStack {
                Button {
                    withAnimation {
                        tabRouter.currentTab = .decks
                    }
                } label: {
                    Image(systemName: "chevron.backward.circle.fill")
                }
                .buttonStyle(PlainButtonStyle())
                
                Text("\(deck?.title ?? NSLocalizedString("Polyglot Cards", comment: "title"))")
                
                Spacer()
                
                Button(action: shareCards) {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                }
                .buttonStyle(PlainButtonStyle())
                .sheet(isPresented: $showShareCSVSheet) {
                    ShareURLView(url: $exportTextURL)
                }
                
                Button(action: addCard) {
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
            
            Spacer()
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    cardsGrid
                    
                    header
                }
            }
            
            if  selectedCard != nil || showDetailCard || selectedPreviewCard != nil {
                VisualEffectView(effect: UIBlurEffect(style: .dark))
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        toggleCard(mode: .both)
                    }
            }
         
            if  selectedCard != nil || showDetailCard {
                CardDetailView(
                    deck: deck,
                    card: selectedCard,
                    onClose: { toggleCard() },
                    namespace: namespace
                )
                    .frame(maxHeight: 800)
            }
            
            if let previewCard = selectedPreviewCard {
                
                if !showShareSheet {
                    VStack {
                        CardView(
                            word: previewCard,
                            languages: languages,
                            visibleLanguages: languages,
                            namespace: namespace,
                            show: true,
                            enableAudio: true
                        )
                            .matchedGeometryEffect(id: "\(previewCard.id)-card", in: namespace)
                            .contentShape(Rectangle())
                        
                        HStack {
                            Button(action: {
                                toggleCard(destination: previewCard, mode: .detail)
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .opacity(0.7)
                                    .font(.largeTitle)
                            }
                        
                            Button(action: {
                                withAnimation(.spring()) {
                                    showShareSheet.toggle()
                                }
                            }) {
                                Image(systemName: "square.and.arrow.up.circle.fill")
                                    .opacity(0.7)
                                    .font(.largeTitle)
                            }
                        }
                        .foregroundColor(.white)
                    }
                    .frame(maxWidth: 600)
                }
                
                
                if showShareSheet {
                    CardShareView(isPresented: $showShareSheet, card: previewCard) {
                        toggleCard(mode: .preview)
                    }
                    .frame(maxWidth: 600)
                    .transition(.scale)
                }
            }
        }
        .onAppear {
            checkRedirect()
        }
        .onChange(of: tabRouter.selectedCard) { _ in
            checkRedirect()
        }
        .onChange(of: tabRouter.addNewCard) { _ in
            checkRedirect()
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onEnded({ value in
                    if value.translation.width > 0 && value.startLocation.x < 20 {
                        withAnimation {
                            tabRouter.currentTab = .decks
                        }
                    }
                })
        )
    }
}

struct ShareURLView: View {
    @Binding var url: URL?
    
    var body: some View {
        VStack {
            ShareSheet(activityItems: [url!])
        }
    }
}
