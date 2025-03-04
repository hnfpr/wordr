// Fixed Bug for Folder Bug

import SwiftUI
import SwiftData

@main
struct WordrApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Folder.self, Flashcard.self)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
        }
        .modelContainer(container)
    }
}