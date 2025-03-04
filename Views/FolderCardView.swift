//ContentView Need Fix UI Not Similar with Design

import SwiftUI

struct FolderCardView: View {
    let folder: Folder
    
    var body: some View {
        VStack(alignment: .leading) {
            if let imageData = folder.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 100)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(height: 100)
                    .overlay(
                        Image(systemName: "folder")
                            .font(.largeTitle)
                            .foregroundColor(.primary.opacity(0.5))
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(folder.title)
                    .font(.headline)
                    .lineLimit(1)
                
                if !folder.desc.isEmpty {
                    Text(folder.desc)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text("\(folder.flashcards.count) cards")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(8)
        }
        .background(Color.primary.opacity(0.05))
        .cornerRadius(10)
    }
}