import SwiftUI

struct FlashcardPreviewView: View {
    let flashcards: [Flashcard]
    
    @State private var currentIndex = 0
    @State private var showingAnswer = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.1)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                            Text("Back")
                        }
                        .foregroundColor(.primary)
                    }
                    .padding()
                    Spacer()
                }
                
                Spacer()
                
                if !flashcards.isEmpty {
                    HStack {
                        Button {
                            withAnimation {
                                showingAnswer = false
                                currentIndex = (currentIndex - 1 + flashcards.count) % flashcards.count
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.largeTitle)
                                .foregroundColor(.primary.opacity(0.5))
                        }
                        .padding()
                        
                        Spacer()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(radius: 5)
                            
                            ScrollView {
                                VStack(spacing: 20) {
                                    if let imageData = flashcards[currentIndex].imageData, 
                                       let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxHeight: 200)
                                            .cornerRadius(8)
                                    }
                                    
                                    if showingAnswer {
                                        Text(flashcards[currentIndex].desc)
                                            .font(.body)
                                            .multilineTextAlignment(.leading)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    } else {
                                        Text(flashcards[currentIndex].title)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .multilineTextAlignment(.center)
                                            .padding()
                                    }
                                    
                                    Button {
                                        withAnimation {
                                            showingAnswer.toggle()
                                        }
                                    } label: {
                                        Text(showingAnswer ? "Show Question" : "Show Answer")
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(Color.primary)
                                            .cornerRadius(8)
                                    }
                                    .padding(.bottom)
                                }
                                .padding()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                showingAnswer = false
                                currentIndex = (currentIndex + 1) % flashcards.count
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.largeTitle)
                                .foregroundColor(.primary.opacity(0.5))
                        }
                        .padding()
                    }
                    
                    Text("\(currentIndex + 1) of \(flashcards.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top)
                } else {
                    Text("No flashcards available")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .onAppear {
            showingAnswer = false
        }
    }
}