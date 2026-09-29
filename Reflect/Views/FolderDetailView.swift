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
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            if sortedNotes.isEmpty {
                emptyNotesView
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(sortedNotes) { note in
                            NavigationLink {
                                EditNoteView(note: note)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
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
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    noteToDelete = note
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete Note", systemImage: "trash")
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .navigationTitle(folder.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddNote = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add Note")
            }
            .sharedBackgroundVisibility(.hidden)
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
    
    private var emptyNotesView: some View {
        VStack(spacing: 8) {
            Text("No notes yet.")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("Create a note to start writing.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func deleteNote(_ note: Note) {
        modelContext.delete(note)
        try? modelContext.save()
        noteToDelete = nil
    }
}

#Preview {
    let folder = Folder(name: "School")
    return NavigationStack {
        FolderDetailView(folder: folder)
    }
    .modelContainer(for: [Folder.self, Note.self], inMemory: true)
}
