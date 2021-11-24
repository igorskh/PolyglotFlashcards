//
//  CardDetailView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 19.11.21.
//

import SwiftUI

struct CardDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var word: Card
    var namespace: Namespace.ID
    var visibleLanguages: [Language]
    
    var body: some View {
        VStack {
            if let imageData = word.image,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: UIScreen.main.bounds.width, maxHeight: 250)
                    .clipped()
                    .clipShape(Rectangle())
                    .contentShape(Rectangle())
                    .padding(.horizontal)
                    .matchedGeometryEffect(id: "card-image", in: namespace)
            }
            
            Button(action: {
                viewContext.delete(word)
                
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    print("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }) {
                Text("Delete")
                    .foregroundColor(Color.red)
            }
            
            Spacer()
        }
        .navigationTitle("Card")
        
    }
}
