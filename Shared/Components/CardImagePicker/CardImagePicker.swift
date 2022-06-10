//
//  CardImagePicker.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 12.12.21.
//

import SwiftUI
import UniformTypeIdentifiers

enum CardImageEditMode {
    case imagePicker
    case imageSearch
}

struct CardImagePicker: View {
    @Namespace var namespace
    
    @StateObject var viewModel: CardImagePickerViewModel = .init()
    
    @State var showPicker: Bool = false
    @State private var dragOver = false
    @State private var imageEditMode: CardImageEditMode = .imagePicker
    @State private var searchRequest: String = ""
    
    var onImageChanged: ((UIImage?) -> Void)?
    
    var height: CGFloat
    var initialImageData: Data?
    
    init(height: CGFloat, initialImageData: Data? = nil, onImageChanged: @escaping (UIImage?) -> Void) {
        self.height = height
        self.initialImageData = initialImageData
        self.onImageChanged = onImageChanged
    }
    
    var imageSelector: some View {
        ZStack {
            if viewModel.showInitialImage || (imageEditMode == .imagePicker && viewModel.uiImage.size == .zero),
               let imageData = initialImageData,
               imageData.count > 0 {
                Image(image: UIImage(data: imageData)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: height)
                    .clipped()
            }
            if imageEditMode == .imageSearch {
                ImageCarouselView(
                    selectedItemID: $viewModel.selectedImageID,
                    images: viewModel.images ?? [],
                    contentMode: .fit,
                    height: height
                )
                    .frame(height: height)
            }
            if imageEditMode == .imagePicker {
                ZStack {
                    Image(image: viewModel.uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        .frame(height: height)
                        .onTapGesture {
                            showPicker.toggle()
                        }
                    if viewModel.uiImage.size == .zero {
                        Button {
                            showPicker.toggle()
                        } label: {
                            Text(LocalizedStringKey("Select image"))
                                .foregroundColor(Color.white)
                                .fontWeight(.bold)
                                .font(.title2)
                                .background(
                                    Color.black.opacity(0.8)
                                )
                        }
                    }
                    
                }
                .sheet(isPresented: $showPicker) {
                    ImagePicker(isOpen: $showPicker, selectedImage: $viewModel.uiImage)
                }
            }
        }
    }
    
    func search() {
        viewModel.searchRequest = searchRequest
        viewModel.getImages()
        
    }
    
    var imageSelectorSwitch: some View {
        HStack {
            Button {
                viewModel.resetImage()
                imageEditMode = .imagePicker
            } label: {
                Image(systemName:  "arrow.uturn.backward.circle.fill")
                    .font(.title)
                    .foregroundColor(.primary)
            }
            .buttonStyle(PlainButtonStyle())
//
            if imageEditMode == .imageSearch {
                Button {
                    withAnimation {
                        imageEditMode = .imagePicker
                    }
                } label: {
                    Image(systemName: "photo.circle.fill")
                        .font(.title)
                        .foregroundColor(.primary)
                    
                }
                .buttonStyle(PlainButtonStyle())
                
                TextField(LocalizedStringKey("Search query"), text: $searchRequest, onCommit: {
                    search()
                })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button {
                    search()
                } label: {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.title)
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
                .matchedGeometryEffect(id: "searchImage", in: namespace)
            } else {
                Button {
                    withAnimation {
                        imageEditMode = .imageSearch
                    }
                } label: {
                    Image(systemName:  "magnifyingglass.circle.fill")
                        .font(.title)
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
                .matchedGeometryEffect(id: "searchImage", in: namespace)

                Text(LocalizedStringKey("Search query"))

                Spacer()
            }
        }
    }
    
    var body: some View {
        VStack {
            imageSelector
            imageSelectorSwitch
                .padding(.horizontal, 20)
        }
        .onChange(of: viewModel.selectedImage) {
            onImageChanged?($0)
        }
        .onDrop(of: [UTType.image], isTargeted: $dragOver) { providers -> Bool in
            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.image", completionHandler: { (data, error) in
                if let data = data,
                   let image = UIImage(data: data) {
                    imageEditMode = .imagePicker
                    viewModel.uiImage = image
                }
            })
            return true
        }
    }
}
