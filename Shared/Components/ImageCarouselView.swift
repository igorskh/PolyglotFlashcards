//
//  ImageCarouselView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 19.11.21.
//

import SwiftUI

struct ImageCarouselView: View {
    #if os(iOS) || os(watchOS) || os(tvOS)
        var cardWidth: CGFloat = UIScreen.main.bounds.width - 20
    #elseif os(macOS)
        var cardWidth: CGFloat = 200
    #endif
    @State var currentItemID = 0
    @Binding var selectedItemID: Int
    let images: [RemoteImage]
    let contentMode: ContentMode
    let height: CGFloat
    
    var body: some View {
        ScrollView(.horizontal) {
            ScrollViewReader { proxy in
                LazyHStack {
                    ForEach(images) { rImage in
                        if #available(iOS 15.0, macOS 12.0, *) {
                            AsyncImage(
                                url: rImage.url,
                                content: { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: contentMode)
                                        .frame(minWidth: cardWidth, maxHeight: height)
                                        .clipped()
                                        .clipShape(Rectangle())
                                        .contentShape(Rectangle())
                                        .padding(.horizontal)
                                        .id(rImage.id)
                                },
                                placeholder: {
                                    ProgressView()
                                        .frame(minWidth: cardWidth, maxHeight: height)
                                }
                            )
                        } else {
                            WebImage(
                                withURL: rImage.url.absoluteString
                            )
                                .aspectRatio(contentMode: contentMode)
                                .frame(minWidth: cardWidth, maxHeight: height)
                                .clipped()
                                .clipShape(Rectangle())
                                .contentShape(Rectangle())
                                .padding(.horizontal)
                                .id(rImage.id)
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
