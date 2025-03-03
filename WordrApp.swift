import SwiftUI
import SwiftData

@main
struct WordrApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Folder.self, Flashcard.self])
    }
}