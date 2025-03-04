//ContentView Need Fix UI Not Similar with Design

import SwiftUI
import SwiftData

struct FolderContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var folder: Folder
    
    @State private var showingCreateSheet = false
    @State private var selectedFlashcard: Flashcard?
    @State private var showingEditSheet = false
    @State private var showingPreviewMode = false
    
    var body: some View {
        VStack {
            if folder.flashcards.isEmpty {
                ContentUnavailableView {
                    Label("No Flashcards", systemImage: "rectangle.on.rectangle")
                } description: {
                    Text("Tap the + button to create your first flashcard.")
                }
            } else {
                List {
                    ForEach(folder.flashcards) { flashcard in
                        FlashcardRowView(flashcard: flashcard)
                            .onTapGesture {
                                selectedFlashcard = flashcard
                                showingEditSheet = true
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    deleteFlashcard(flashcard)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                
                if !folder.flashcards.isEmpty {
                    Button("Preview Mode") {
                        showingPreviewMode = true
                    }
                    .buttonStyle(.bordered)
                    .padding(.bottom)
                }
            }
        }
        .navigationTitle(folder.title)
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
    }
    
    private func addFlashcard(title: String, description: String, imageData: Data?) {
        let newFlashcard = Flashcard(title: title, desc: description, imageData: imageData, folder: folder)
        folder.flashcards.append(newFlashcard)
        try? modelContext.save()
    }
    
    private func updateFlashcard(flashcard: Flashcard, title: String, description: String, imageData: Data?) {
        flashcard.title = title
        flashcard.desc = description
        flashcard.imageData = imageData
        try? modelContext.save()
    }
    
    private func deleteFlashcard(_ flashcard: Flashcard) {
        folder.flashcards.removeAll { $0.id == flashcard.id }
        modelContext.delete(flashcard)
        try? modelContext.save()
    }
}