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
            ZStack {
                PaperTheme.screenBackground
                    .ignoresSafeArea()
                
                if folders.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(folders) { folder in
                            NavigationLink {
                                FolderDetailView(folder: folder)
                            } label: {
                                FolderRowView(folder: folder)
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(PaperTheme.screenBackground)
                            .swipeActions(edge: .leading) {
                                Button {
                                    startRename(folder)
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                .tint(PaperTheme.inkSecondary)
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
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
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
                            .foregroundStyle(PaperTheme.ink)
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
        .tint(PaperTheme.ink)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text("No folders yet.")
                .font(.system(.title3, design: .serif).weight(.medium))
                .foregroundStyle(PaperTheme.ink)
            
            Text("Create your first folder to start organizing notes.")
                .font(.system(.subheadline))
                .foregroundStyle(PaperTheme.inkSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button {
                showingAddFolder = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("New Folder")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(PaperTheme.ink)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .overlay(
                    Rectangle()
                        .stroke(PaperTheme.ink, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
            
            Spacer()
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

private struct FolderRowView: View {
    let folder: Folder
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 14) {
                Image(systemName: "folder")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(PaperTheme.inkSecondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(folder.name)
                        .font(.system(.body, design: .serif).weight(.medium))
                        .foregroundStyle(PaperTheme.ink)
                    
                    HStack(spacing: 6) {
                        Text("\(folder.notes.count) \(folder.notes.count == 1 ? "note" : "notes")")
                        Text("—")
                        Text(folder.createdAt.formatted(date: .abbreviated, time: .omitted))
                    }
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(PaperTheme.inkSecondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            
            Rectangle()
                .fill(PaperTheme.divider)
                .frame(height: 1)
        }
    }
}

#Preview {
    FolderListView()
        .modelContainer(for: [Folder.self, Note.self], inMemory: true)
}
