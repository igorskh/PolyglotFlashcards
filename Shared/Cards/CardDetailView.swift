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
    
    @State private var offset = CGSize.zero
    @State private var zoomFactor: CGFloat = 1.0
    @State private var editEnabled: Bool = false
    @State private var showDecks: Bool = false
    	
    init(card: Card? = nil, onClose: (() -> Void)? = nil, namespace: Namespace.ID) {
        viewModel = CardDetailViewModel(card: card)
        
        if let onClose = onClose {
            self.onClose = onClose
        }
        self.namespace = namespace
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
                Text("No image selected")
            }
        }
    }
    
    var header: some View {
        VStack {
            ZStack {
                VStack {
                    if viewModel.images != nil && viewModel.nQueuedRequests == 0 {
                        ImageCarouselView(
                            selectedItemID: $viewModel.selectedImageID,
                            images: viewModel.images ?? [],
                            contentMode: .fill,
                            height: 200
                        )
                    } else {
                        image
                    }
                }
                .frame(height: 200)
                .clipped()
                
                VStack {
                    HStack {
                        Text(viewModel.card != nil ? "Edit Card" : "New Card")
                            .font(.title)
                            .foregroundColor(.white)
                        Spacer()
                        
                        Image(systemName: editEnabled ? "eye.circle.fill" : "pencil.circle.fill" )
                            .opacity(0.7)
                            .font(.title)
                            .onTapGesture {
                                editEnabled.toggle()
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
            .frame(height: 200)
            .clipped()
        }
    }
    
    var translationsList: some View {
        ScrollView {
            ForEach(viewModel.translations.indices) { i in
                HStack {
                    Text("\(viewModel.translations[i].target.flag)")
                    Spacer()
                    
                    if editEnabled {
                        TextField("", text: $viewModel.translations[i].translation)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        AttributedText(viewModel.translations[i].attributedString)
                            .padding(5)
                            .background(Color.white)
                            .onTapGesture {
                                editEnabled.toggle()
                            }
                    }
                    
                    if editEnabled {
                        Button {
                            viewModel.getTranslation(from: viewModel.translations[i].target)
                        } label: {
                            Image(systemName: "globe")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Button {
                        viewModel.speak(at: i)
                    } label: {
                        Image(systemName: "speaker.wave.3")
                    }
                    .buttonStyle(PlainButtonStyle())
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
                title: viewModel.card == nil ? "Create" : "Save",
                color: Color.accentColor
            ) {
                viewModel.saveCard(context: viewContext) {
                    closeCard()
                }
            }
            
            if viewModel.card != nil {
                FilledButton(
                    title: "Delete",
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
            } else if editEnabled {
                Text("Enter text in fields below")
            } else {
                Text(" ")
            }
            
            HStack {
                Text("Decks")
                
                ScrollView([.horizontal]) {
                    HStack {
                        ForEach(viewModel.decks) { d in
                            DeckCapsuleView(title: d.title ?? "N/A") {
                                viewModel.decks.remove(at: viewModel.decks.firstIndex(of: d)!)
                            }
                        }
                    }
                }
                .onTapGesture {}
                
                Spacer()
                
                Button {
                    showDecks.toggle()
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title)
                }
                .buttonStyle(PlainButtonStyle())
                .sheet(isPresented: $showDecks) {
                    DecksListView(selectedDecks: $viewModel.decks)
                }
                
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            translationsList
                .padding(.horizontal)
            
            Spacer()
            
            buttons
                .padding(.horizontal)
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
                    self.offset = .zero
                    self.zoomFactor = 1.0
                }
        )
        .onAppear {
            editEnabled = viewModel.card == nil
        }
    }
}
