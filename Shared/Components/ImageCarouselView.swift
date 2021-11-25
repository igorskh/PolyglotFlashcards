//
//  ImageCarouselView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 19.11.21.
//

import SwiftUI

struct ImageCarouselView: View {
    let cardWidth = UIScreen.main.bounds.width - 20
    @State var currentItemID = 0
    @Binding var selectedItemID: Int
    let images: [RemoteImage]
    
    var body: some View {
        ScrollView(.horizontal) {
            ScrollViewReader { proxy in
                LazyHStack {
                    ForEach(images) { rImage in
                        if #available(iOS 15.0, *) {
                            AsyncImage(
                                url: rImage.url,
                                content: { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(minWidth: UIScreen.main.bounds.width, maxHeight: 250)
                                        .clipped()
                                        .clipShape(Rectangle())
                                        .contentShape(Rectangle())
                                        .padding(.horizontal)
                                        .id(rImage.id)
                                },
                                placeholder: {
                                    ProgressView()
                                        .frame(minWidth: UIScreen.main.bounds.width, maxHeight: 250)
                                }
                            )
                        }
                    }
                
                }
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onEnded({ value in
                    if value.translation.width < 0 {
                        if currentItemID < images.count {
                            currentItemID += 1
                        }
                    } else if value.translation.width > 0 {
                        if currentItemID > 0 {
                            currentItemID -= 1
                        }
                    }
                }))
                .onChange(of: currentItemID) { _ in
                    selectedItemID = currentItemID
                    withAnimation {
                        proxy.scrollTo(images[currentItemID].id, anchor: .center)
                    }
                }
            }
        }
        
    }
}
