//
//  DecksPicker.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 03.12.21.
//

import SwiftUI

struct DecksPicker: View {
    @Binding var selectedDecks: [Deck]
    @State var showDecks: Bool = false
    
    var canEdit: Bool
    var showAny: Bool
    var selectOnlyOne: Bool = false
    
    var body: some View {
        HStack {
            Text(LocalizedStringKey("Decks"))
                
            ScrollView([.horizontal]) {
                HStack {
                    ForEach(selectedDecks) { d in
                        DeckCapsuleView(title: d.title ?? NSLocalizedString("N/A", comment: "Not available")) {
                            selectedDecks.remove(at: selectedDecks.firstIndex(of: d)!)
                        }
                    }
                    if selectedDecks.count == 0 && showAny {
                        DeckCapsuleView(title: NSLocalizedString("Any", comment: "Any deck"))
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primary.opacity(0.2), lineWidth: 1)
            )
            .onTapGesture {}
            
            Spacer()
            
            Button {
                showDecks.toggle()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
            }
            .buttonStyle(PlainButtonStyle())
            
            .sheet(isPresented: $showDecks) {
                DecksListView(selectedDecks: $selectedDecks, canEdit: canEdit, selectOnlyOne: selectOnlyOne)
            }
        }
        .padding(5)
    }
}
