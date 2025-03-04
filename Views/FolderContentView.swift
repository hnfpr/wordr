//ContentView Need Fix UI Not Similar with Design New

import SwiftUI
import SwiftData

struct FolderContentView: View {
    let folder: Folder
    @Environment(\.modelContext) private var modelContext
    @State private var selectedFlashcard: Flashcard?
    @State private var showingEditSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            if folder.flashcards.isEmpty {
                ContentUnavailableView {
                    Label("No Flashcards", systemImage: "rectangle.on.rectangle")
                } description: {
                    Text("Tap the + button to create your first flashcard.")
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(folder.flashcards) { flashcard in
                            HStack(spacing: 12) {
                                if let imageData = flashcard.imageData,
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipped()
                                        .cornerRadius(8)
                                } else {
                                    Rectangle()
                                        .fill(Color(.systemGray5))
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(8)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(flashcard.title)
                                        .font(.headline)
                                    Text(flashcard.desc)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray5), lineWidth: 1)
                            )
                            .onTapGesture {
                                selectedFlashcard = flashcard
                                showingEditSheet = true
                            }
                        }
                    }
                    .padding()
                }
            }
            
            if !folder.flashcards.isEmpty {
                Button(action: {
                    showingPreviewMode = true
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
            }
        }
        .navigationTitle(folder.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingCreateSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            FlashcardEditView(mode: .create) { title, description, imageData in
                addFlashcard(title: title, description: description, imageData: imageData)
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showingEditSheet, onDismiss: {
            selectedFlashcard = nil
        }) {
            if let flashcard = selectedFlashcard {
                FlashcardEditView(mode: .edit(flashcard)) { title, description, imageData in
                    updateFlashcard(flashcard: flashcard, title: title, description: description, imageData: imageData)
                }
                .presentationDetents([.large])
            }
        }
        .fullScreenCover(isPresented: $showingPreviewMode) {
            FlashcardPreviewView(flashcards: folder.flashcards)
        }
        .sheet(item: $selectedFlashcard) { flashcard in
            FlashcardEditView(
                mode: .edit(flashcard),
                onSave: { title, description, imageData in
                    flashcard.title = title
                    flashcard.desc = description
                    flashcard.imageData = imageData
                    try? modelContext.save()
                },
                onDelete: {
                    modelContext.delete(flashcard)
                    try? modelContext.save()
                }
            )
        }
    }
}