//ContentView Need Fix UI Not Similar with Design New



import SwiftUI
import PhotosUI

enum FlashcardEditMode: Equatable {
    case create
    case edit(Flashcard)
    
    static func == (lhs: FlashcardEditMode, rhs: FlashcardEditMode) -> Bool {
        switch (lhs, rhs) {
        case (.create, .create):
            return true
        case let (.edit(lhsFlashcard), .edit(rhsFlashcard)):
            return lhsFlashcard.id == rhsFlashcard.id
        default:
            return false
        }
    }
}

struct FlashcardEditView: View {
    let mode: FlashcardEditMode
    let onSave: (String, String, Data?) -> Void
    let onDelete: (() -> Void)?
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    @Environment(\.dismiss) private var dismiss
    
    init(mode: FlashcardEditMode, 
         onSave: @escaping (String, String, Data?) -> Void,
         onDelete: (() -> Void)? = nil) {
        self.mode = mode
        self.onSave = onSave
        self.onDelete = onDelete
        
        switch mode {
        case .create:
            _title = State(initialValue: "")
            _description = State(initialValue: "")
            _imageData = State(initialValue: nil)
        case .edit(let flashcard):
            _title = State(initialValue: flashcard.title)
            _description = State(initialValue: flashcard.desc)
            _imageData = State(initialValue: flashcard.imageData)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Image picker first
                VStack(alignment: .leading, spacing: 8) {
                    Text("Image (Optional)")
                        .font(.headline)
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray5))
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .overlay(
                                    Image(systemName: "plus")
                                        .foregroundColor(.black)
                                        .padding(20)
                                        .background(Circle().fill(.white))
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.headline)
                    TextField("", text: $title)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal, 16)
                
                // Description field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (Optional)")
                        .font(.headline)
                    TextEditor(text: Binding(
                        get: { description },
                        set: { newValue in
                            if newValue.count <= 420 {
                                description = newValue
                            }
                        }
                    ))
                    .frame(height: 200)
                    .scrollContentBackground(.hidden)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground))
                            .strokeBorder(Color(.systemGray4), lineWidth: 0.5)
                    )
                    .overlay(
                        Text("\(description.count)/420")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(8),
                        alignment: .bottomTrailing
                    )
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Add Flashcard button
                Button {
                    if !title.isEmpty {
                        onSave(title, description, imageData)
                        dismiss()
                    }
                } label: {
                    Text(mode == .create ? "Add Flashcard" : "Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)  // Changed to black background
                        .foregroundColor(.white)  // Changed to white text
                        .cornerRadius(12)
                }
                .padding(16)
                .disabled(title.isEmpty)
            }
            .navigationTitle(mode == .create ? "Add Flashcard" : "Edit Flashcard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if case .edit = mode {
                        Button {
                            onDelete?()  // Call the delete callback
                            dismiss()    // Dismiss the view after deletion
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
}
