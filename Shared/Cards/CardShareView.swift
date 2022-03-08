//
//  CardShareView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 16.01.22.
//

import SwiftUI

struct CardShareView: View {
    @Preference(\.languages) var languages
    @Preference(\.filteredLanguages) var filteredLanguages
    @Namespace var namespace
    let imageSize: CGSize = CGSize(width: 400, height: 300)
    
    @State private var showShareSheet = false
    @State private var uiImage: UIImage?
    
    @Binding var isPresented: Bool
    
    var card: Card
    var onDismiss: (() -> Void)?
    
    func dismiss() {
        if let onDismiss = onDismiss {
            onDismiss()
        }
        withAnimation(.spring()) {
            isPresented = false
        }
    }
    
    var cardContent: some View {
        VStack {
            CardView(word: card, languages: languages, visibleLanguages: filteredLanguages, namespace: namespace, alignment: .leading)
                .contentShape(Rectangle())
            
            ZStack {
                HStack(alignment: .bottom) {
                    Text("Polyglot Flashcards")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                HStack {
                    Spacer()
                    Image("ara")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 100)
                        .offset(x: 20, y: 20)
                        .padding(.top, -20)
                }
                .ignoresSafeArea()
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(red: 38/255, green: 121/255, blue: 198/255, opacity: 1), Color(red: 3/255, green: 227/255, blue: 251/255, opacity: 1)]), startPoint: .bottomLeading, endPoint: .topTrailing)
                .ignoresSafeArea(edges: .all)
        )
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Share this card")
                
                Spacer()
                
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .onTapGesture {
                        dismiss()
                    }
            }
            .font(.title)
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .foregroundColor(.white)
            .background(Color.black)
            
            cardContent
                .clipped()
                .clipShape(Rectangle())
            
            FilledButton(title: NSLocalizedString("Share", comment: "Share"), color: .accentColor) {
                showShareSheet.toggle()
            }
            .sheet(isPresented: $showShareSheet) {
                ShareImageView(uiImage: $uiImage)
            }
            .padding()
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if gesture.translation.height > 50 {
                        dismiss()
                    }
                }
        )
        .background(Color.black)
        .onAppear {
            uiImage = cardContent.asImage()
        }
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
    }
}


struct ShareImageView: View {
    @Binding var uiImage: UIImage?
    
    var body: some View {
        VStack {
            ShareSheet(activityItems: [uiImage!])
        }
    }
}
