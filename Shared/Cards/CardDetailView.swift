//
//  CardDetailView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import SwiftUI

struct CardDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: CardDetailViewModel
    var onClose: () -> Void = {}
    var namespace: Namespace.ID
    var deck: Deck?
    
    @State private var offset = CGSize.zero
    @State private var zoomFactor: CGFloat = 1.0
    @State private var editCardEnabled: Bool = false
    
    @State private var showTranslationOptionsID: Int = -1
    @State private var showTranslationOptions: Bool = false
    @State private var showDecks: Bool = false
    
    init(
        deck: Deck? = nil,
        card: Card? = nil,
        onClose: (() -> Void)? = nil,
        namespace: Namespace.ID)
    {
        self.deck = deck
        viewModel = CardDetailViewModel(card: card)
        
        if let onClose = onClose {
            self.onClose = onClose
        }
        self.namespace = namespace
        if let currentDeck = deck,
           card == nil {
            viewModel.decks.append(currentDeck)
        }
    }
    
    func closeCard() {
        onClose()
    }
    
    var image: some View {
        ZStack {
            if let card = viewModel.card,
               let uiImage = card.uiImage {
                Image(image: uiImage)
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .offset(x: offset.width/6, y: -1*abs(offset.height)/6)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .matchedGeometryEffect(id: "\(card.id.hashValue)-title", in: namespace)
            } else {
                Text(LocalizedStringKey("No image selected"))
            }
        }
    }
    
    var header: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                VStack {
                    if editCardEnabled {
                        CardImagePicker(searchRequest: $viewModel.query, height: 200) { img in
                            viewModel.setImage(from: img.pngData()!)
                        }
                        .padding(.horizontal)
                    }
                    else {
                        image
                            .frame(height: 200)
                    }
                }
                .clipped()
                
                VStack {
                    HStack {
                        Text(viewModel.card != nil
                             ? LocalizedStringKey("Edit Card")
                             : LocalizedStringKey("New Card")
                        )
                            .font(.title)
                            .foregroundColor(.white)
                        Spacer()
                        
                        Image(systemName: editCardEnabled ? "eye.circle.fill" : "pencil.circle.fill" )
                            .opacity(0.7)
                            .font(.title)
                            .onTapGesture {
                                editCardEnabled.toggle()
                            }
                        
                        Image(systemName: "xmark.circle.fill")
                            .opacity(0.7)
                            .font(.title)
                            .onTapGesture {
                                closeCard()
                            }
                    }
                    .padding(.vertical)
                    .padding(.horizontal)
                    .foregroundColor(Color.white)
                    .background(
                        Color.black.opacity(0.5)
                    )
                    
                    Spacer()
                }
                
            }
        }
    }
    
    var translationsList: some View {
        ScrollView {
            ForEach(viewModel.translations.indices) { i in
                HStack {
                    Text("\(viewModel.translations[i].target.flag)")
                    Spacer()
                    
                    if editCardEnabled {
                        TextField("", text: $viewModel.translations[i].translation)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        AttributedText(viewModel.translations[i].attributedString)
                            .padding(5)
                            .background(Color.white)
                            .onTapGesture {
                                editCardEnabled.toggle()
                            }
                    }
                    
                    if editCardEnabled {
                        Button {
                            viewModel.getTranslation(from: viewModel.translations[i].target)
                        } label: {
                            Image(systemName: "globe")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if viewModel.options[i].isFormalityAvailable || viewModel.options[i].isLocaleAvailable {
                            Button {
                                showTranslationOptionsID = i
                            } label: {
                                Image(systemName: "ellipsis.circle.fill")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    Button {
                        viewModel.speak(at: i)
                    } label: {
                        Image(systemName: "speaker.wave.3")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contextMenu {
                        Group {
                            Button("Auto", action: {
                                viewModel.speak(at: i)
                                
                            })
                            Button("VoiceOver", action: {
                                viewModel.speak(at: i, engine: .voiceOver)
                                
                            })
                            Button("Google TTS", action: {
                                viewModel.speak(at: i, engine: .googleTTS)
                                
                            })
                        }
                    }
                }
                .matchedGeometryEffect(id: "\(viewModel.card?.id.hashValue ?? -1)-\(viewModel.translations[i].target.code)", in: namespace)
                .padding(.vertical, 5)
                .font(.title3)
            }
        }
        .onTapGesture {}
    }
    
    var buttons: some View {
        HStack {
            FilledButton(
                title: viewModel.card == nil
                ? NSLocalizedString("Create", comment: "Create Card")
                : NSLocalizedString("Save", comment: "Save Card"),
                color: Color.accentColor
            ) {
                viewModel.saveCard(context: viewContext) {
                    closeCard()
                }
            }
            
            if viewModel.card != nil {
                FilledButton(
                    title: NSLocalizedString("Delete", comment: "Delete Card"),
                    color: Color.red
                ) {
                    viewModel.deleteCard(context: viewContext) {
                        closeCard()
                    }
                }
            }
        }
        .padding(.vertical)
    }
    
    var body: some View {
        VStack {
            header
            
            if viewModel.errorMessage != "" {
                Text(viewModel.errorMessage)
                    .padding(.horizontal)
                    .foregroundColor(.red)
            }
            
            if viewModel.nQueuedRequests > 0 {
                ProgressView()
            } else if editCardEnabled {
                Text(LocalizedStringKey("Enter text in the fields below"))
            } else {
                Text(" ")
            }
            
            
            DecksPicker(selectedDecks: $viewModel.decks, canEdit: true, showAny: false)
                .padding(.horizontal)
                .padding(.bottom)
                
            translationsList
                .padding(.horizontal)
            
            Spacer()
            
            buttons
                .padding(.horizontal)
        }
        .onChange(of: showTranslationOptionsID) { value in
            showTranslationOptions = value > -1
        }
        .sheet(isPresented: $showTranslationOptions, onDismiss: { showTranslationOptionsID = -1 }) {
            TranslationOptionsEditView(
                language: viewModel.languages[showTranslationOptionsID],
                options: $viewModel.options[showTranslationOptionsID]
            )
        }
        .frame(maxWidth: 600)
        .background(
            Rectangle()
                .colorInvert()
                .ignoresSafeArea().onTapGesture {}
        )
        .offset(x: 0, y: offset.height)
        .rotation3DEffect(.degrees(Double(offset.width / 5)), axis: (x: 0.0, y: 1.0, z: 0.0))
        .scaleEffect(self.zoomFactor)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    self.zoomFactor = gesture.startLocation.y/gesture.location.y
                    self.offset = gesture.translation
                    
                    if abs(self.offset.height) > 50 {
                        closeCard()
                    }
                }
                .onEnded { _ in
                    if abs(self.offset.height) < 50 {
                        self.offset = .zero
                        self.zoomFactor = 1.0
                    }
                }
        )
        .onAppear {
            offset = CGSize.zero
            zoomFactor = 1.0
            editCardEnabled = viewModel.card == nil
        }
    }
}
