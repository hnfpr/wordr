//ContentView Need Fix UI Not Similar with Design New


import SwiftUI
import SwiftData

// Move extensions to file scope
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.title) private var folders: [Folder]
    @StateObject private var subscriptionManager = SubscriptionManager()
    @State private var showingCreateSheet = false
    @State private var showingUpgradeAlert = false
    @State private var selectedFolder: Folder?
    @State private var showingEditSheet = false
    
    // Move functions outside of body
    private func addFolder(title: String, description: String, imageData: Data?) {
        withAnimation {
            let newFolder = Folder(title: title, desc: description, imageData: imageData)
            modelContext.insert(newFolder)
            do {
                try modelContext.save()
                print("Folder saved successfully: \(title)")
                print("Current folder count: \(folders.count)")
            } catch {
                print("Error saving folder: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateFolder(folder: Folder, title: String, description: String, imageData: Data?) {
        folder.title = title
        folder.desc = description
        folder.imageData = imageData
        try? modelContext.save()
    }
    
    private func deleteFolder(_ folder: Folder) {
        modelContext.delete(folder)
        try? modelContext.save()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom navigation bar
                HStack {
                    Text("Wordr")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        if !subscriptionManager.isPremium && folders.count >= 3 {
                            showingUpgradeAlert = true
                        } else {
                            showingCreateSheet = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search", text: .constant(""))
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding()
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(folders) { folder in
                            NavigationLink(value: folder) {
                                VStack(alignment: .leading, spacing: 0) {
                                    if let imageData = folder.imageData,
                                       let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(4/3, contentMode: .fill)
                                            .frame(maxWidth: .infinity)
                                            .clipped()
                                            .cornerRadius(8, corners: [.topLeft, .topRight])
                                    } else {
                                        Rectangle()
                                            .fill(Color(.systemGray5))
                                            .aspectRatio(4/3, contentMode: .fit)
                                            .frame(maxWidth: .infinity)
                                            .cornerRadius(8, corners: [.topLeft, .topRight])
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(folder.title)
                                            .font(.headline)
                                        Text("\(folder.flashcards.count) card")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(12)
                                }
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray5), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contextMenu {
                                Button("Edit") {
                                    selectedFolder = folder
                                    showingEditSheet = true
                                }
                                
                                Button("Delete", role: .destructive) {
                                    deleteFolder(folder)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)  // Hide the default navigation bar
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if !subscriptionManager.isPremium && folders.count >= 3 {
                            showingUpgradeAlert = true
                        } else {
                            showingCreateSheet = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !subscriptionManager.isPremium {
                        Button("Upgrade") {
                            showingUpgradeAlert = true
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.primary.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            .navigationDestination(for: Folder.self) { folder in
                FolderContentView(folder: folder)
            }
            .sheet(isPresented: $showingCreateSheet) {
                FolderEditView(mode: FolderEditMode.create) { title, description, imageData in
                    addFolder(title: title, description: description, imageData: imageData)
                }
                .presentationDetents([.large])
            }
            .sheet(isPresented: $showingEditSheet, onDismiss: {
                selectedFolder = nil
            }) {
                if let folder = selectedFolder {
                    FolderEditView(mode: FolderEditMode.edit(folder)) { title, description, imageData in
                        updateFolder(folder: folder, title: title, description: description, imageData: imageData)
                    }
                    .presentationDetents([.large])
                }
            }
            .alert("Upgrade to Pro", isPresented: $showingUpgradeAlert) {
                Button("Upgrade Now") {
                    subscriptionManager.upgradeToPremium()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Free users can create up to 3 folders. Upgrade to Pro for unlimited folders!")
            }
            .environmentObject(subscriptionManager)
        }
    }
}
