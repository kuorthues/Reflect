//
//  FolderListView.swift
//  Reflect
//

import SwiftUI
import SwiftData

struct FolderListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.createdAt, order: .forward) private var folders: [Folder]
    
    @State private var showingAddFolder = false
    @State private var folderToRename: Folder?
    @State private var renameText = ""
    @State private var showingRenameAlert = false
    
    @State private var folderToDelete: Folder?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if folders.isEmpty {
                    emptyStateView
                } else {
                    bookshelfView
                }
            }
            .navigationTitle("Reflect")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddFolder = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add Folder")
                }
                .sharedBackgroundVisibility(.hidden)
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
    
    private var bookshelfView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(folders) { folder in
                    NavigationLink {
                        FolderDetailView(folder: folder)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(folder.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            
                            Text("\(folder.notes.count) \(folder.notes.count == 1 ? "note" : "notes")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
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
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(Color(.separator))
                            .frame(width: 1)
                    }
                    .overlay(alignment: .trailing) {
                        Rectangle()
                            .fill(Color(.separator))
                            .frame(width: 1)
                    }
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color(.separator))
                            .frame(height: 1)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Text("No folders yet.")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("Create a folder to start writing.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

#Preview {
    FolderListView()
        .modelContainer(for: [Folder.self, Note.self], inMemory: true)
}
