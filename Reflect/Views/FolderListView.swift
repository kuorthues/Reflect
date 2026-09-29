//
//  FolderListView.swift
//  Reflect
//

import SwiftUI
import SwiftData

struct FolderListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.name) private var folders: [Folder]
    
    @State private var showingAddFolder = false
    @State private var folderToRename: Folder?
    @State private var renameText = ""
    @State private var showingRenameAlert = false
    
    @State private var folderToDelete: Folder?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            Group {
                if folders.isEmpty {
                    ContentUnavailableView {
                        Label("No Folders", systemImage: "folder")
                    } description: {
                        Text("Create a folder to start organizing your notes.")
                    } actions: {
                        Button {
                            showingAddFolder = true
                        } label: {
                            Label("New Folder", systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(folders) { folder in
                            NavigationLink {
                                FolderDetailView(folder: folder)
                            } label: {
                                FolderRowView(folder: folder)
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    startRename(folder)
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    confirmDelete(folder)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .contextMenu {
                                Button {
                                    startRename(folder)
                                } label: {
                                    Label("Rename Folder", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive) {
                                    confirmDelete(folder)
                                } label: {
                                    Label("Delete Folder", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Reflect")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddFolder = true
                    } label: {
                        Label("Add Folder", systemImage: "folder.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFolder) {
                AddFolderView()
            }
            .alert("Rename Folder", isPresented: $showingRenameAlert) {
                TextField("Folder Name", text: $renameText)
                Button("Cancel", role: .cancel) {
                    folderToRename = nil
                    renameText = ""
                }
                Button("Save") {
                    saveRename()
                }
            } message: {
                Text("Enter a new name for this folder.")
            }
            .alert("Delete Folder", isPresented: $showingDeleteAlert, presenting: folderToDelete) { folder in
                Button("Delete", role: .destructive) {
                    deleteFolder(folder)
                }
                Button("Cancel", role: .cancel) {
                    folderToDelete = nil
                }
            } message: { folder in
                let noteCount = folder.notes.count
                if noteCount == 0 {
                    Text("Are you sure you want to delete \"\(folder.name)\"?")
                } else if noteCount == 1 {
                    Text("Are you sure you want to delete \"\(folder.name)\"? The note inside will also be deleted.")
                } else {
                    Text("Are you sure you want to delete \"\(folder.name)\"? All \(noteCount) notes inside will also be deleted.")
                }
            }
        }
    }
    
    private func startRename(_ folder: Folder) {
        folderToRename = folder
        renameText = folder.name
        showingRenameAlert = true
    }
    
    private func saveRename() {
        guard let folder = folderToRename else { return }
        let trimmed = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            folder.name = trimmed
            try? modelContext.save()
        }
        folderToRename = nil
        renameText = ""
    }
    
    private func confirmDelete(_ folder: Folder) {
        folderToDelete = folder
        showingDeleteAlert = true
    }
    
    private func deleteFolder(_ folder: Folder) {
        modelContext.delete(folder)
        try? modelContext.save()
        folderToDelete = nil
    }
}

private struct FolderRowView: View {
    let folder: Folder
    
    var body: some View {
        HStack {
            Image(systemName: "folder.fill")
                .foregroundStyle(.tint)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(folder.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text("\(folder.notes.count) \(folder.notes.count == 1 ? "note" : "notes")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 4)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    FolderListView()
        .modelContainer(for: [Folder.self, Note.self], inMemory: true)
}
