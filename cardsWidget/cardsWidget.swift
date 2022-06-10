//
//  cardsWidget.swift
//  cardsWidget
//
//  Created by Igor Kim on 05.01.22.
//

import WidgetKit
import SwiftUI
import Intents
import CoreData

struct Provider: IntentTimelineProvider {
    var persistance: PersistenceController = .shared
    
    func placeholder(in context: Context) -> CardEntry {
        CardEntry(date: Date(), card: nil, configuration: ConfigurationIntent(), count: -1)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (CardEntry) -> ()) {
        
        let fetchRequest: NSFetchRequest<Card>
        fetchRequest = Card.fetchRequest()
        
        var count = 0
        do {
            count = try persistance.container.viewContext.count(for: fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        
        let entry = CardEntry(date: Date(), card: nil, configuration: configuration, count: count)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [CardEntry] = []
        
        let viewContext = persistance.container.viewContext
        let currentDate = Date()
        for hourOffset in 0 ..< 1 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            
            let fetchRequest: NSFetchRequest<Card>
            fetchRequest = Card.fetchRequest()
            
            var count = 0
            var card: Card?
            do {
                count = try viewContext.count(for: fetchRequest)
                
                fetchRequest.fetchLimit = 1
                fetchRequest.fetchOffset = Int.random(in: 0..<count)
                card = try viewContext.fetch(fetchRequest).first
            } catch {
                print(error.localizedDescription)
            }
            
            let entry = CardEntry(date: entryDate, card: card, configuration: configuration, count: count)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct CardEntry: TimelineEntry {
    let date: Date
    let card: Card?
    let configuration: ConfigurationIntent
    let count: Int
}

let maxRowCount = 4

struct CardView: View {
    @Environment(\.widgetFamily) var family
    
    @Preference(\.filteredLanguages) var storedFilteredLanguages
    
    var card: Card
    
    func buildDeepLink() -> String {
        return card.objectID.uriRepresentation().absoluteString
    }

    
    func buildVariants() -> [CardVariant] {
        guard  let variants = card.variants?.sortedArray(using: []) as? [CardVariant] else {
            return []
        }
        
        var results: [CardVariant] = []
        
        for v in variants {
            if let language = Language(rawValue: v.language_code ?? ""),
               storedFilteredLanguages.contains(language) {
                results.append(v)
                if results.count == maxRowCount {
                    break
                }
            }
        }
        return results
    }
    
    var body: some View {
            ZStack {
                Color.black.opacity(0.5)
                
                VStack(spacing: 8) {
                    ForEach(buildVariants()) { v in
                        if let language = Language(rawValue: v.language_code ?? ""),
                           storedFilteredLanguages.contains(language) {
                            HStack {
                                Text("\(language.flag)")
                                Text("\(v.text ?? "")")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                
                                Spacer()
                            }
                            
                        }
                    }
                }
                .widgetURL (URL(string: "widget://card/\(buildDeepLink())")!)
                .padding(10)
                    
                if family != .systemSmall {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Link(destination: URL(string: "widget://newCard")!) {
                                
                                Image(systemName: "plus.circle.fill")
                                    .font(.custom("", size: 48))
                                    .foregroundColor(.white)
                                    .opacity(0.6)
                            }
                        }
                    }
                    .padding(5)
                }
            }
            .background(
                Group {
                    if let imageData = card.image,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                    }
                    else {
                        Color.black
                    }
                }
            )
        
    }
}

struct cardsWidgetEntryView : View {
    @Preference(\.filteredLanguages) var storedFilteredLanguages
    
    var entry: Provider.Entry
    
    var body: some View {
        if let card = entry.card {
            CardView(card: card)
        } else {
            ZStack {
                Color.black.opacity(0.5)
                VStack(spacing: 10) {
                    HStack {
                        Text("🇺🇸")
                        Text("Cat")
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("🇷🇺")
                        Text("Кошка")
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                }
                .padding(10)
            }
            .background(
                Image(uiImage: UIImage(named: "sample_cat")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            )
            
        }
    }
}

@main
struct cardsWidget: Widget {
    let kind: String = "cardsWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            cardsWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Random Polyglot Card")
        .description("This widget shows a random Polyglot Card")
    }
}

struct cardsWidget_Previews: PreviewProvider {
    static var previews: some View {
        cardsWidgetEntryView(entry: CardEntry(date: Date(), card: nil, configuration: ConfigurationIntent(), count: 0))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
