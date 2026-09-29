//
//  FolderDetailView.swift
//  Reflect
//

import SwiftUI
import SwiftData

struct FolderDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var folder: Folder
    
    @State private var showingAddNote = false
    @State private var noteToDelete: Note?
    @State private var showingDeleteAlert = false
    @State private var refreshID = UUID()
    
    private var sortedNotes: [Note] {
        _ = refreshID
        return folder.notes.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    var body: some View {
        Group {
            if sortedNotes.isEmpty {
                ContentUnavailableView {
                    Label("No Notes", systemImage: "note.text")
                } description: {
                    Text("Create your first note in this folder.")
                } actions: {
                    Button {
                        showingAddNote = true
                    } label: {
                        Label("New Note", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                List {
                    ForEach(sortedNotes) { note in
                        NavigationLink {
                            EditNoteView(note: note)
                        } label: {
                            NoteRowView(note: note)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                noteToDelete = note
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                noteToDelete = note
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete Note", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(folder.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddNote = true
                } label: {
                    Label("Add Note", systemImage: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(folder: folder)
        }
        .onAppear {
            refreshID = UUID()
        }
        .alert("Delete Note?", isPresented: $showingDeleteAlert, presenting: noteToDelete) { note in
            Button("Delete", role: .destructive) {
                deleteNote(note)
            }
            Button("Cancel", role: .cancel) {
                noteToDelete = nil
            }
        } message: { note in
            Text("Are you sure you want to delete \"\(note.title)\"?")
        }
    }
    
    private func deleteNote(_ note: Note) {
        modelContext.delete(note)
        try? modelContext.save()
        noteToDelete = nil
    }
}

private struct NoteRowView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            if !note.content.isEmpty {
                Text(note.content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Text(note.updatedAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let folder = Folder(name: "Sample Folder")
    return NavigationStack {
        FolderDetailView(folder: folder)
    }
    .modelContainer(for: [Folder.self, Note.self], inMemory: true)
}
