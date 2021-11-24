//
//  AddCardView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 18.10.21.
//

import SwiftUI

struct AddCardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: AddTranslationViewModel
    @Environment(\.presentationMode) var presentationMode
    	
    init(card: Card? = nil) {
        viewModel = AddTranslationViewModel(card: card)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.errorMessage != "" {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                }
                
                ForEach(viewModel.translations.indices) { i in
                    HStack {
                        Text("\(viewModel.translations[i].target.flag)")
                        Spacer()
                        TextField("", text: $viewModel.translations[i].translation)
                        Button {
                            viewModel.getTranslation(from: viewModel.translations[i].target)
                        } label: { Image(systemName: "arrow.left.arrow.right") }
                    }
                    .padding(.vertical, 5)
                    .font(.title3)
                }
                if viewModel.nQueuedRequests > 0 {
                    ProgressView()
                }
                
                Spacer()
                
                if viewModel.nQueuedRequests == 0 {
                    ImageCarouselView(
                        selectedItemID: $viewModel.selectedImageID,
                        images: viewModel.images ?? []
                    )
                }
                
                Button(action: {
                    viewModel.saveCard(context: viewContext) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text(viewModel.card == nil ? "Create" : "Save")
                }
            }
            .padding()
            .navigationTitle("New Card")
        }
    }
}
