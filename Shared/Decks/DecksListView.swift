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
    
    @ObservedObject var viewModel: DecksListViewModel = .init()
    
    @State var errorText: String = ""
    @Binding var selectedDecks: [Deck]
    
    var canEdit: Bool
    var canSelect: Bool = true
    
    init(selectedDecks: Binding<[Deck]>, canEdit: Bool, canSelect: Bool = true) {
        self._selectedDecks = selectedDecks
        self.canEdit = canEdit
        self.canSelect = canSelect
    }
    
    func addDeck() {
        errorText = ""
        
        viewModel.searchText = viewModel.searchText.trimmingCharacters(in: [" "])
        if viewModel.searchText == "" {
            errorText = NSLocalizedString("Enter deck title", comment: "Enter deck title")
            return
        }
        
        let exists = viewModel.decks.contains { d in
            d.title!.lowercased() == viewModel.searchText.lowercased()
        }
        if exists {
            errorText = NSLocalizedString("Deck with this name already exists", comment: "Deck with this name already exists")
            return
        }
        
        let deck = Deck(context: viewContext)
        deck.title = viewModel.searchText
        
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
            errorText = NSLocalizedString("This deck contains cards", comment: "This deck contains cards")
            return
        }
        if let cards = deck.cards,
           cards.count > 0 {
            errorText = NSLocalizedString("This deck contains cards", comment: "This deck contains cards")
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
                Text(LocalizedStringKey("Your Decks"))
                
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
                    TextField(NSLocalizedString("Deck Title", comment: "Deck Title"), text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                if canEdit {
                    Button {
                        addDeck()
                    } label: { Text(LocalizedStringKey("Create")) }
                }
                
                if errorText != "" {
                    Text(errorText)
                        .foregroundColor(.red)
                }
            }
            
            ScrollView {
                ForEach(viewModel.searchResults) { d in
                    HStack {
                        Text(d.title ?? NSLocalizedString("N/A", comment: "N/A"))
                        
                        Spacer()
                        
                        if canEdit {
                            Button {
                                deleteDeck(deck: d)
                            } label: {
                                Image(systemName: "trash.circle.fill")
                                    .font(.title)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    .background(
                        selectedDecks.contains(d)
                        ? Color.green.opacity(0.5)
                        : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !canSelect {
                            return
                        }
                        if selectedDecks.contains(d) {
                            selectedDecks.remove(at: selectedDecks.firstIndex(of: d)!)
                        } else {
                            selectedDecks.append(d)
                        }
                    }
                }
            }
        }.padding()
    }
}
