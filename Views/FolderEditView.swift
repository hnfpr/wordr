import SwiftUI
import PhotosUI

enum EditMode {
    case create
    case edit(Folder)
}

struct FolderEditView: View {
    let mode: EditMode
    let onSave: (String, String, Data?) -> Void
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    @Environment(\.dismiss) private var dismiss
    
    init(mode: EditMode, onSave: @escaping (String, String, Data?) -> Void) {
        self.mode = mode
        self.onSave = onSave
        
        switch mode {
        case .create:
            _title = State(initialValue: "")
            _description = State(initialValue: "")
            _imageData = State(initialValue: nil)
        case .edit(let folder):
            _title = State(initialValue: folder.title)
            _description = State(initialValue: folder.desc)
            _imageData = State(initialValue: folder.imageData)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Image") {
                    VStack {
                        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                        } else {
                            Rectangle()
                                .fill(Color.primary.opacity(0.1))
                                .frame(height: 200)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.primary.opacity(0.5))
                                )
                        }
                        
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Text("Select Image")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .onChange(of: selectedItem) { _, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    imageData = data
                                }
                            }
                        }
                        
                        if imageData != nil {
                            Button("Remove Image", role: .destructive) {
                                imageData = nil
                                selectedItem = nil
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                
                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle(FlashcardEditMode == .create ? "New Folder" : "Edit Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !title.isEmpty {
                            onSave(title, description, imageData)
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
