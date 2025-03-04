//ContentView Need Fix UI Not Similar with Design New


import SwiftUI

struct FlashcardPreviewView: View {
    let flashcards: [Flashcard]
    
    @State private var currentIndex = 0
    @State private var showingAnswer = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                Spacer()
                Text("\(currentIndex + 1)/\(flashcards.count)")
                    .font(.headline)
            }
            .padding()
            
            // Card content
            VStack(spacing: 20) {
                if let imageData = flashcards[currentIndex].imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .cornerRadius(12)
                }
                
                Text(flashcards[currentIndex].title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                // Preview and navigation buttons
                VStack(spacing: 16) {
                    Button {
                        withAnimation {
                            showingAnswer = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "eye")
                            Text("Preview")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    HStack(spacing: 16) {
                        Button {
                            withAnimation {
                                currentIndex = (currentIndex - 1 + flashcards.count) % flashcards.count
                                showingAnswer = false
                            }
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.black)
                            .cornerRadius(12)
                        }
                        
                        Button {
                            withAnimation {
                                currentIndex = (currentIndex + 1) % flashcards.count
                                showingAnswer = false
                            }
                        } label: {
                            HStack {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(16)
        }
        .sheet(isPresented: $showingAnswer) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let imageData = flashcards[currentIndex].imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .cornerRadius(12)
                    }
                    
                    Text(flashcards[currentIndex].title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(flashcards[currentIndex].desc)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(16)
            }
            .presentationDetents([.large])
        }
    }
}
