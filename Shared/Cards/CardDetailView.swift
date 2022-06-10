//
//  CardDetailView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import SwiftUI

struct CardDetailView: View {
    @ObservedObject var viewModel: CardDetailViewModel
    var onClose: () -> Void = {}
    var namespace: Namespace.ID
    var deck: Deck?
    
    @State private var showShareSheet: Bool = false
    
    @State private var showTranslationOptionsID: Int = -1
    @State private var showTranslationOptions: Bool = false
    
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
    
    func translationContextMenu(target: Language? = nil) -> some View {
        Group {
            Button("Auto", action: {
                if let target = target {
                    viewModel.getTranslation(
                        from: target
                    )
                } else {
                    viewModel.translateAll()
                }
            })
            Button("DeepL", action: {
                if let target = target {
                    viewModel.getTranslation(
                        from: target,
                        engine: .deepL
                    )
                } else {
                    viewModel.translateAll(engine: .deepL)
                }
            })
            Button("Google", action: {
                if let target = target {
                    viewModel.getTranslation(
                        from: target,
                        engine: .google
                    )
                } else {
                    viewModel.translateAll(engine: .google)
                }
            })
            Button("Yandex", action: {
                if let target = target {
                    viewModel.getTranslation(
                        from: target,
                        engine: .yandex
                    )
                } else {
                    viewModel.translateAll(engine: .yandex)
                }
            })
        }
    }
    
    func ttsContextMenu(index: Int) -> some View {
        Group {
            Button("Auto", action: {
                viewModel.speak(at: index)
                
            })
            Button("VoiceOver", action: {
                viewModel.speak(at: index, engine: .voiceOver)
                
            })
            Button("Google TTS", action: {
                viewModel.speak(at: index, engine: .googleTTS)
                
            })
        }
    }
    
    var translationsList: some View {
        ScrollView {
            ForEach(viewModel.translations.indices) { i in
                HStack {
                    Text("\(viewModel.translations[i].target.flag)")
                    Spacer()
                    
                    ZStack(alignment: .top) {
//                        TextField("", text: $viewModel.translations[i].translation)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .multilineTextAlignment(.leading)
                        
                        DismissibleTextEditor(text: $viewModel.translations[i].translation, tag: i, preferredLanguage: viewModel.translations[i].target.code)
                            { _ in
                                viewModel.getTranslation(
                                    from: viewModel.translations[i].target
                                )
                            }
                            .onTapGesture {
                                viewModel.isTranslationFieldFocused = true
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary.opacity(0.5), lineWidth: 0.5)
                            )
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                viewModel.clearTranslation(at: i)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .opacity(0.4)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.trailing, 5)
                        }
                        .padding(.top, 8)
                    }
                
                    Button {
                        viewModel.getTranslation(
                            from: viewModel.translations[i].target
                        )
                    } label: {
                        Image(systemName: "globe")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contextMenu {
                        translationContextMenu(target: viewModel.translations[i].target)
                    }
                    
//                    if viewModel.options[i].isFormalityAvailable || viewModel.options[i].isLocaleAvailable {
//                        Button {
//                            showTranslationOptionsID = i
//                        } label: {
//                            Image(systemName: "ellipsis.circle.fill")
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//
                    
                    Button {
                        viewModel.speak(at: i)
                    } label: {
                        Image(systemName: "speaker.wave.3")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contextMenu {
                        ttsContextMenu(index: i)
                    }
                }
                .matchedGeometryEffect(id: "\(viewModel.card?.id.hashValue ?? -1)-\(viewModel.translations[i].target.code)", in: namespace)
                .padding(.vertical, 5)
                .font(.title3)
            }
        }
        .onTapGesture {
#if !os(macOS)
            hideKeyboard()
#endif
        }
    }
    
    var buttons: some View {
        HStack {
            FilledButton(
                title: NSLocalizedString("Translate", comment: "Translate Card"),
                color: Color.accentColor
            ) {
                viewModel.translateAll()
            }
            .contextMenu {
                translationContextMenu()
            }
            
            FilledButton(
                title: viewModel.card == nil
                ? NSLocalizedString("Create", comment: "Create Card")
                : NSLocalizedString("Save", comment: "Save Card"),
                color: Color.accentColor
            ) {
                viewModel.saveCard() {
                    closeCard()
                }
            }
            
            if viewModel.card != nil {
                FilledButton(
                    title: NSLocalizedString("Delete", comment: "Delete Card"),
                    color: Color.red
                ) {
                    viewModel.deleteCard() {
                        closeCard()
                    }
                }
            }
        }
        .padding(.vertical)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                CardDetailHeaderView(onShare: {
                    withAnimation(.spring()) {
                        showShareSheet.toggle()
                    }
                }, onClose: {
                    closeCard()
                })
                .environmentObject(viewModel)
                .onTapGesture {
                    viewModel.isTranslationFieldFocused = false
                }
                
                if viewModel.errorMessage != "" {
                    Text(viewModel.errorMessage)
                        .padding(.horizontal)
                        .foregroundColor(.red)
                }
                
                if viewModel.nQueuedRequests > 0 {
                    ProgressView()
                }
                
                if !viewModel.isHeaderHidden {
                    DecksPicker(selectedDecks: $viewModel.decks, canEdit: true, showAny: false, selectOnlyOne: true)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                    
                translationsList
                    .padding(.horizontal)
                
                Spacer()
                
                buttons
                    .padding(.horizontal)
            }
            
            if showShareSheet,
               let card = viewModel.card {
                VisualEffectView(effect: UIBlurEffect(style: .dark))
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showShareSheet = false
                        }
                    }
                
                CardShareView(isPresented: $showShareSheet, card: card)
                    .transition(.move(edge: .bottom))
            }
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
            Color.primary.colorInvert()
                .ignoresSafeArea()
        )
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if gesture.startLocation.y > 200 {
                        return
                    }
                    if gesture.translation.height > 50 {
                        closeCard()
                    }
                }
        )
#if !os(macOS)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) {
            viewModel.adjustForKeyboard(notification: $0)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) {
            viewModel.adjustForKeyboard(notification: $0)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
            withAnimation(.spring()) {
                showShareSheet = true
            }
        }
#endif
    }
}
