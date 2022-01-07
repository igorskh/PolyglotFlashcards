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

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "PolyglotFlashcards")

        let storeURL = URL.storeURL(for: "group.one.beagile.polyglotflashcards", databaseName: "data")
        
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.isReadOnly = true

        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}

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
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            
            let fetchRequest: NSFetchRequest<Card>
            fetchRequest = Card.fetchRequest()
            fetchRequest.fetchLimit = 1
            
            var count = 0
            var card: Card?
            do {
                card = try persistance.container.viewContext.fetch(fetchRequest).first
                
                count = try persistance.container.viewContext.count(for: fetchRequest)
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

struct cardsWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if let card = entry.card,
           let imageData = card.image,
           let uiImage = UIImage(data: imageData) {
            ZStack {
                Image(uiImage: uiImage)
                    .resizable()
                
                Color.black.opacity(0.4)
                
                VStack {
                    if let variants = card.variants?.sortedArray(using: []) as? [CardVariant] {
                        ForEach(variants) { v in
                            HStack {
                                Text("\((Language(rawValue: v.language_code ?? "") ?? .Unknown).flag)")
                                Text("\(v.text ?? "")")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding(10)
            }
        } else {
            Text("\(entry.count)")
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
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct cardsWidget_Previews: PreviewProvider {
    static var previews: some View {
        cardsWidgetEntryView(entry: CardEntry(date: Date(), card: nil, configuration: ConfigurationIntent(), count: 0))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
