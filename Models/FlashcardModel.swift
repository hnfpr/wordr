import Foundation
import SwiftData

@Model
final class Flashcard {
    var id: UUID
    var title: String
    var desc: String
    var imageData: Data?
    var folder: Folder?
    
    init(id: UUID = UUID(), title: String, desc: String = "", imageData: Data? = nil, folder: Folder? = nil) {
        self.id = id
        self.title = title
        self.desc = desc
        self.imageData = imageData
        self.folder = folder
    }
}