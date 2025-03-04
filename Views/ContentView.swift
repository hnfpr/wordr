import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.title) private var folders: [Folder]  // Add sorting to ensure proper updates
    @StateObject private var subscriptionManager = SubscriptionManager()
    @State private var showingCreateSheet = false
    @State private var showingUpgradeAlert = false
    @State private var selectedFolder: Folder?
    @State private var showingEditSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                    // In ContentView, modify the navigation part:
                    ForEach(folders) { folder in
                        NavigationLink(value: folder) {
                            FolderCardView(folder: folder)
                        }
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
            .navigationTitle("Wordr")
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
                FolderEditView(mode: .create) { title, description, imageData in
                    addFolder(title: title, description: description, imageData: imageData)
                }
                .presentationDetents([.large])
            }
            .sheet(isPresented: $showingEditSheet, onDismiss: {
                selectedFolder = nil
            }) {
                if let folder = selectedFolder {
                    FolderEditView(mode: .edit(folder)) { title, description, imageData in
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
}
