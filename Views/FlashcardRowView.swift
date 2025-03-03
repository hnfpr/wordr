import SwiftUI

struct FlashcardRowView: View {
    let flashcard: Flashcard
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageData = flashcard.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "rectangle.on.rectangle")
                            .foregroundColor(.primary.opacity(0.5))
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(flashcard.title)
                    .font(.headline)
                    .lineLimit(1)
                
                if !flashcard.desc.isEmpty {
                    Text(flashcard.desc)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}