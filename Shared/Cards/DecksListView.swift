//
//  DecksListView.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 01.12.21.
//

import SwiftUI

struct DecksListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Deck.createdAt, ascending: false)],
        animation: .default)
    private var decks: FetchedResults<Deck>
    
    @State var newDeckTitle: String = ""
    @State var errorText: String = ""
    @Binding var selectedDecks: [Deck]
    
    func addDeck() {
        errorText = ""
        
        newDeckTitle = newDeckTitle.trimmingCharacters(in: [" "])
        if newDeckTitle == "" {
            errorText = "Enter deck title"
            return
        }
        
        let exists = decks.contains { d in
            d.title!.lowercased() == newDeckTitle.lowercased()
        }
        if exists {
            errorText = "Deck with this name already exists"
            return
        }
        
        let deck = Deck(context: viewContext)
        deck.title = newDeckTitle
        
        do {
            try viewContext.save()
            selectedDecks.append(deck)
        } catch {
            let nsError = error as NSError
            errorText = nsError.userInfo.description
            print("Unresolved error \(nsError.code) \(nsError), \(nsError.userInfo)")
        }
    }
    
    func deleteDeck(deck: Deck) {
        errorText = ""
        if  selectedDecks.contains(deck) {
            errorText = "This deck contains cards"
            return
        }
        if let cards = deck.cards,
           cards.count > 0 {
            errorText = "This deck contains cards"
            return
        }
        
        viewContext.delete(deck)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            errorText = nsError.userInfo.description
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Your Decks")
                
                Spacer()
                
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                }
                .buttonStyle(PlainButtonStyle())
            }.font(.title)
            
            HStack {
                TextField("Deck Title", text: $newDeckTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button {
                    addDeck()
                } label: { Text("Create") }
            }
            
            if errorText != "" {
                Text(errorText)
                    .foregroundColor(.red)
            }
            
            ScrollView {
                ForEach(decks) { d in
                    HStack {
                        Text(d.title ?? "N/A")
                        Spacer()
                        Button {
                            deleteDeck(deck: d)
                        } label: {
                            Image(systemName: "trash.circle.fill")
                                .font(.title)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                    .onTapGesture {
                        if selectedDecks.contains(d) {
                            selectedDecks.remove(at: selectedDecks.firstIndex(of: d)!)
                        } else {
                            selectedDecks.append(d)
                        }
                    }
                    .background(
                        selectedDecks.contains(d)
                        ? Color.green.opacity(0.5)
                        : Color.clear
                    )
                }
            }
        }.padding()
    }
}
