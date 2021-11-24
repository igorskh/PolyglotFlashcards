//
//  CardDetailView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import SwiftUI

struct CardDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: AddTranslationViewModel
    @Environment(\.presentationMode) var presentationMode
    var onClose: () -> Void = {}
    var namespace: Namespace.ID
    
    @State private var offset = CGSize.zero
    @State private var zoomFactor: CGFloat = 1.0
    	
    init(card: Card? = nil, onClose: (() -> Void)? = nil, namespace: Namespace.ID) {
        viewModel = AddTranslationViewModel(card: card)
        if let onClose = onClose {
            self.onClose = onClose
        }
        self.namespace = namespace
    }
    
    func closeCard() {
        presentationMode.wrappedValue.dismiss()
        onClose()
    }
    
    
    var background: some View {
        ZStack {
            if let card = viewModel.card,
               let imageData = card.image,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .offset(x: offset.width/6, y: -1*abs(offset.height)/6)
                    .aspectRatio(contentMode: .fit)
                    .matchedGeometryEffect(id: "\(card.id.hashValue)-title", in: namespace)
            }
        }
    }
    
    var header: some View {
        ZStack {
            VStack {
                if viewModel.images != nil && viewModel.nQueuedRequests == 0 {
                    ImageCarouselView(
                        selectedItemID: $viewModel.selectedImageID,
                        images: viewModel.images ?? []
                    )
                } else {
                    background
                }
            }
            .frame(height: 200)
            
            
        }
        .frame(height: 200)
        .clipped()
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.card != nil ? "Edit Card" : "New Card")
                    .font(.title)
                Spacer()
                Image(systemName: "xmark.circle.fill")
                    .opacity(0.7)
                    .font(.title)
                    .onTapGesture {
                        closeCard()
                    }
            }
            
            header
        
            if viewModel.errorMessage != "" {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
            }
            
            if viewModel.nQueuedRequests > 0 {
                ProgressView()
            }
            
            ScrollView {
                ForEach(viewModel.translations.indices) { i in
                    HStack {
                        Text("\(viewModel.translations[i].target.flag)")
                        Spacer()
                        TextField("", text: $viewModel.translations[i].translation)
                        Button {
                            viewModel.getTranslation(from: viewModel.translations[i].target)
                        } label: { Image(systemName: "arrow.left.arrow.right") }
                    }
                    .matchedGeometryEffect(id: "\(viewModel.card?.id.hashValue ?? -1)-\(viewModel.translations[i].target.code)", in: namespace)
                    .padding(.vertical, 5)
                    .font(.title3)
                }
            }
            .onTapGesture {}
            
            
            Spacer()
            
            HStack {
                Button(action: {
                    viewModel.saveCard(context: viewContext) {
                        closeCard()
                    }
                }) {
                    Text(viewModel.card == nil ? "Create" : "Save")
                }
                
                if viewModel.card != nil {
                    Spacer()
                    Button(action: {
                        viewModel.deleteCard(context: viewContext) {
                            closeCard()
                        }
                    }) {
                        Text("Delete")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
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
                }
                .onEnded { _ in
                    if abs(self.offset.height) > 50 {
                        closeCard()
                    } else {
                        self.offset = .zero
                        self.zoomFactor = 1.0
                    }
                }
        )
    }
}
