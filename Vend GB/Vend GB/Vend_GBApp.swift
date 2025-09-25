//
//  Vend_GBApp.swift
//  Vend GB
//
//  Created by Matthew Moore on 16/09/2025.
//

import SwiftUI
import SwiftData

@main
struct Vend_GBApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ProductsView()
        }
        .modelContainer(sharedModelContainer)
    }
}
