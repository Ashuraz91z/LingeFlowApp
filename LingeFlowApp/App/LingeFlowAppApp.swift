//
//  LingeFlowAppApp.swift
//  LingeFlowApp
//
//  Created by Lucas Fernandes on 14/05/2026.
//

import SwiftUI
import SwiftData

@main
struct LingeFlowAppApp: App {
    private let modelContainer: ModelContainer

    init() {
        do {
            let configuration = ModelConfiguration(
                cloudKitDatabase: .private("iCloud.com.luxaudere.lingeflow")
            )
            modelContainer = try ModelContainer(for: LaundryRoutine.self, configurations: configuration)
        } catch {
            fatalError("Impossible de configurer SwiftData: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
