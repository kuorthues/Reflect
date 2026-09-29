//
//  EditNoteView.swift
//  Reflect
//

import SwiftUI
import SwiftData

struct EditNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var note: Note
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Note title", text: $title)
            }
            
            Section(header: Text("Content")) {
                TextEditor(text: $content)
                    .frame(minHeight: 220)
            }
            
            Section(header: Text("Details")) {
                LabeledContent("Folder", value: note.folder?.name ?? "None")
                LabeledContent("Created", value: note.createdAt.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("Last Modified", value: note.updatedAt.formatted(date: .abbreviated, time: .shortened))
            }
            
            Section {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Label("Delete Note", systemImage: "trash")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onAppear {
            title = note.title
            content = note.content
        }
        .alert("Delete Note?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteNote()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this note?")
        }
    }
    
    private func saveChanges() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        note.title = trimmedTitle
        note.content = content
        note.updatedAt = Date()
        try? modelContext.save()
        dismiss()
    }
    
    private func deleteNote() {
        modelContext.delete(note)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    let folder = Folder(name: "Work")
    let note = Note(title: "Meeting Notes", content: "Discuss project status", folder: folder)
    return NavigationStack {
        EditNoteView(note: note)
    }
    .modelContainer(for: [Folder.self, Note.self], inMemory: true)
}
