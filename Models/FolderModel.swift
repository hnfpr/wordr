//ContentView Need Fix UI Not Similar with Design

import Foundation
import SwiftData

@Model
final class Folder {
    var id: UUID
    var title: String
    var desc: String
    var imageData: Data?
    @Relationship(deleteRule: .cascade, inverse: \Flashcard.folder)
    var flashcards: [Flashcard] = []
    
    init(id: UUID = UUID(), title: String, desc: String = "", imageData: Data? = nil) {
        self.id = id
        self.title = title
        self.desc = desc
        self.imageData = imageData
    }
}