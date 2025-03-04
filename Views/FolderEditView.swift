//ContentView Need Fix UI Not Similar with Design New

import SwiftUI
import PhotosUI

enum FolderEditMode: Equatable {
    case create
    case edit(Folder)
}

struct FolderEditView: View {
    let mode: FolderEditMode
    let onSave: (String, String, Data?) -> Void
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    @Environment(\.dismiss) private var dismiss
    
    init(mode: FolderEditMode, onSave: @escaping (String, String, Data?) -> Void) {
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
            VStack(spacing: 16) {
                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.headline)
                    TextField("", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal, 16)
                
                // Image picker
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
                .onChange(of: selectedItem) { _, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            imageData = data
                        }
                    }
                }
                
                Spacer()
                
                // Add Folder button
                Button {
                    if !title.isEmpty {
                        onSave(title, description, imageData)
                        dismiss()
                    }
                } label: {
                    Text(mode == FolderEditMode.create ? "Add Folder" : "Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(16)
                .disabled(title.isEmpty)
            }
            .navigationTitle(mode == FolderEditMode.create ? "Add Folder" : "Edit Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
    }
}
