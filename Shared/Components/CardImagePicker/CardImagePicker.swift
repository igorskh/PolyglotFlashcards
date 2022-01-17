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
    
    @ObservedObject var viewModel: CardImagePickerViewModel = .init()
    
    @State var imageEditMode: CardImageEditMode = .imagePicker
    @State var uiImage: UIImage = UIImage()
    @State var showPicker: Bool = false
    @State private var dragOver = false
    @State var searchRequest: String = ""
    
    var height: CGFloat
    var onImageChanged: (UIImage) -> Void
    
    
    var body: some View {
        VStack {
            if imageEditMode == .imageSearch {
                ImageCarouselView(
                    selectedItemID: $viewModel.selectedImageID,
                    images: viewModel.images ?? [],
                    contentMode: .fit,
                    height: height
                )
                    .onChange(of: viewModel.selectedImageID) {
                        if let images = viewModel.images,
                           $0 > -1,
                           $0 < images.count  {
                            URLSession.shared.dataTask(with: images[$0].url) { data, _, _ in
                                if let data = data,
                                   let uiImage = UIImage(data: data) {
                                    onImageChanged(uiImage)
                                }
                            }.resume()
                        }
                    }
                    .frame(height: height)
            }
            if imageEditMode == .imagePicker {
                ZStack {
                    Image(image: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        .frame(height: height)
                        .onTapGesture {
                            showPicker.toggle()
                        }
                    if uiImage.size == .zero {
                        Button {
                            showPicker.toggle()
                        } label: {
                            Text(LocalizedStringKey("Select image"))
                        }
                    }
                    
                }
                .onChange(of: uiImage) {
                    onImageChanged($0)
                }
                .sheet(isPresented: $showPicker) {
                    ImagePicker(isOpen: $showPicker, selectedImage: $uiImage)
                }
            }
            
            HStack {
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
                    
                    TextField(LocalizedStringKey("Search query"), text: $searchRequest)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button {
                        viewModel.getImages(query: searchRequest)
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
        .onDrop(of: [UTType.image], isTargeted: $dragOver) { providers -> Bool in
            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.image", completionHandler: { (data, error) in
                if let data = data,
                   let image = UIImage(data: data) {
                    imageEditMode = .imagePicker
                    uiImage = image
                    onImageChanged(image)
                }
            })
            return true
        }
    }
}
