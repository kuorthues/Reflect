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
                PaperTheme.shelfWall
                    .ignoresSafeArea()
                
                if folders.isEmpty {
                    emptyBookshelfView
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Top cornice plank of the bookcase
                            BookshelfPlankView(height: 14)
                            
                            // Shelves for each folder
                            ForEach(folders) { folder in
                                ShelfRowView(
                                    folder: folder,
                                    onRename: { startRename(folder) },
                                    onDelete: { confirmDelete(folder) }
                                )
                            }
                            
                            // Fill remaining screen with clean empty shelves to complete the bookcase
                            if folders.count < 4 {
                                ForEach(0..<(4 - folders.count), id: \.self) { index in
                                    EmptyShelfRowView(
                                        onAdd: { showingAddFolder = true },
                                        isInteractive: index == 0
                                    )
                                }
                            }
                            
                            // Solid base plank of the bookcase
                            BookshelfPlankView(height: 18)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 36)
                    }
                }
            }
            .navigationTitle("Reflect")
            .navigationBarTitleDisplayMode(.large)
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
                Text("Enter a new name for this shelf folder.")
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
                    Text("Are you sure you want to delete \"\(folder.name)\"? The note on this shelf will also be deleted.")
                } else {
                    Text("Are you sure you want to delete \"\(folder.name)\"? All \(noteCount) notes on this shelf will also be deleted.")
                }
            }
        }
        .tint(PaperTheme.ink)
    }
    
    private var emptyBookshelfView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                BookshelfPlankView(height: 14)
                
                ZStack {
                    Rectangle()
                        .fill(PaperTheme.shelfWall)
                        .frame(height: 180)
                    
                    HStack {
                        Rectangle()
                            .fill(PaperTheme.shelfFrame)
                            .frame(width: 10)
                        Spacer()
                        Rectangle()
                            .fill(PaperTheme.shelfFrame)
                            .frame(width: 10)
                    }
                    .frame(height: 180)
                    
                    VStack(spacing: 14) {
                        Text("Your bookshelf is empty.")
                            .font(.system(.title3, design: .serif).weight(.medium))
                            .foregroundStyle(PaperTheme.ink)
                        
                        Text("Create your first folder to add a shelf.")
                            .font(.system(.subheadline))
                            .foregroundStyle(PaperTheme.inkSecondary)
                        
                        Button {
                            showingAddFolder = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                Text("New Folder")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(PaperTheme.ink)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 9)
                            .overlay(
                                Rectangle()
                                    .stroke(PaperTheme.ink, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                }
                
                BookshelfPlankView(height: 14)
                
                EmptyShelfRowView(onAdd: { showingAddFolder = true }, isInteractive: false)
                EmptyShelfRowView(onAdd: { showingAddFolder = true }, isInteractive: false)
                
                BookshelfPlankView(height: 18)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 36)
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

private struct ShelfRowView: View {
    let folder: Folder
    let onRename: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationLink {
                FolderDetailView(folder: folder)
            } label: {
                ZStack(alignment: .bottomLeading) {
                    // Shelf space background
                    Rectangle()
                        .fill(PaperTheme.shelfWall)
                        .frame(height: 115)
                    
                    // Left and right vertical bookcase uprights
                    HStack {
                        Rectangle()
                            .fill(PaperTheme.shelfFrame)
                            .frame(width: 10)
                        Spacer()
                        Rectangle()
                            .fill(PaperTheme.shelfFrame)
                            .frame(width: 10)
                    }
                    .frame(height: 115)
                    
                    // Shelf contents: Folder details on left, books on right
                    HStack(alignment: .bottom, spacing: 12) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(folder.name)
                                .font(.system(.title3, design: .serif).weight(.semibold))
                                .foregroundStyle(PaperTheme.ink)
                                .lineLimit(1)
                            
                            Text("\(folder.notes.count) \(folder.notes.count == 1 ? "note" : "notes")")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(PaperTheme.inkSecondary)
                        }
                        .padding(.leading, 24)
                        .padding(.bottom, 16)
                        
                        Spacer()
                        
                        // Notebooks resting on the shelf
                        BooksOnShelfView(count: folder.notes.count)
                            .padding(.trailing, 24)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 115, alignment: .bottom)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button {
                    onRename()
                } label: {
                    Label("Rename Shelf", systemImage: "pencil")
                }
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete Shelf", systemImage: "trash")
                }
            }
            
            // Solid shelf board plank
            BookshelfPlankView(height: 14)
        }
    }
}

private struct EmptyShelfRowView: View {
    let onAdd: () -> Void
    var isInteractive: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(PaperTheme.shelfWall)
                    .frame(height: 115)
                
                HStack {
                    Rectangle()
                        .fill(PaperTheme.shelfFrame)
                        .frame(width: 10)
                    Spacer()
                    Rectangle()
                        .fill(PaperTheme.shelfFrame)
                        .frame(width: 10)
                }
                .frame(height: 115)
                
                if isInteractive {
                    Button {
                        onAdd()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .regular))
                            Text("New Shelf")
                                .font(.system(size: 13, weight: .medium, design: .serif))
                        }
                        .foregroundStyle(PaperTheme.inkSecondary.opacity(0.8))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .overlay(
                            Rectangle()
                                .stroke(PaperTheme.inkSecondary.opacity(0.35), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            BookshelfPlankView(height: 14)
        }
    }
}

private struct BooksOnShelfView: View {
    let count: Int
    
    private let bookConfigs: [(width: CGFloat, height: CGFloat, color: Color)] = [
        (13, 52, PaperTheme.bookPaper),
        (15, 60, PaperTheme.bookKraft),
        (12, 46, PaperTheme.bookTerracotta),
        (14, 64, PaperTheme.bookLinen),
        (11, 50, PaperTheme.bookCharcoal),
        (16, 56, PaperTheme.bookPaper),
        (13, 48, PaperTheme.bookKraft),
        (15, 62, PaperTheme.bookTerracotta)
    ]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<min(count, 8), id: \.self) { index in
                let config = bookConfigs[index % bookConfigs.count]
                ZStack(alignment: .top) {
                    Rectangle()
                        .fill(config.color)
                        .frame(width: config.width, height: config.height)
                        .overlay(
                            Rectangle()
                                .stroke(PaperTheme.ink.opacity(0.25), lineWidth: 1)
                        )
                    
                    // Subtle spine detail band
                    Rectangle()
                        .fill(PaperTheme.ink.opacity(0.2))
                        .frame(width: config.width - 2, height: 2)
                        .padding(.top, 5)
                }
            }
        }
    }
}

private struct BookshelfPlankView: View {
    var height: CGFloat = 14
    
    var body: some View {
        VStack(spacing: 0) {
            // Top highlight line of shelf board
            Rectangle()
                .fill(PaperTheme.shelfPlankTop)
                .frame(height: 2)
            
            // Solid shelf board
            Rectangle()
                .fill(PaperTheme.shelfPlank)
                .frame(height: height)
                .overlay(
                    Rectangle()
                        .stroke(PaperTheme.shelfLine.opacity(0.35), lineWidth: 0.5)
                )
            
            // Under-shelf shadow line
            Rectangle()
                .fill(PaperTheme.shelfPlankShadow)
                .frame(height: 2)
        }
    }
}

#Preview {
    FolderListView()
        .modelContainer(for: [Folder.self, Note.self], inMemory: true)
}
