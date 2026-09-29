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
            PaperTheme.screenBackground
                .ignoresSafeArea()
            
            if sortedNotes.isEmpty {
                emptyNotesView
            } else {
                List {
                    ForEach(sortedNotes) { note in
                        NavigationLink {
                            EditNoteView(note: note)
                        } label: {
                            NotePaperRowView(note: note)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(PaperTheme.screenBackground)
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
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
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
                        .foregroundStyle(PaperTheme.ink)
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
        .tint(PaperTheme.ink)
    }
    
    private var emptyNotesView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text("No notes yet.")
                .font(.system(.title3, design: .serif).weight(.medium))
                .foregroundStyle(PaperTheme.ink)
            
            Text("Create your first note.")
                .font(.system(.subheadline))
                .foregroundStyle(PaperTheme.inkSecondary)
            
            Button {
                showingAddNote = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("New Note")
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
    
    private func deleteNote(_ note: Note) {
        modelContext.delete(note)
        try? modelContext.save()
        noteToDelete = nil
    }
}

private struct NotePaperRowView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.title)
                .font(.system(.headline, design: .serif).weight(.semibold))
                .foregroundStyle(PaperTheme.ink)
                .lineLimit(1)
            
            if !note.content.isEmpty {
                Text(note.content)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(PaperTheme.inkSecondary)
                    .lineLimit(2)
                    .lineSpacing(3)
            }
            
            Rectangle()
                .fill(PaperTheme.divider)
                .frame(height: 1)
                .padding(.top, 2)
            
            HStack {
                Text(note.updatedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(PaperTheme.inkSecondary)
                
                Spacer()
            }
        }
        .padding(16)
        .background(PaperTheme.paper)
        .overlay(
            Rectangle()
                .stroke(PaperTheme.paperBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
        .contentShape(Rectangle())
    }
}

#Preview {
    let folder = Folder(name: "Journal")
    return NavigationStack {
        FolderDetailView(folder: folder)
    }
    .modelContainer(for: [Folder.self, Note.self], inMemory: true)
}
