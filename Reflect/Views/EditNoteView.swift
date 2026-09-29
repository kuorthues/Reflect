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
        VStack(alignment: .leading, spacing: 0) {
            TextField("Title", text: $title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
            
            Divider()
                .padding(.horizontal, 20)
            
            ZStack(alignment: .topLeading) {
                if content.isEmpty {
                    Text("Start writing...")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .allowsHitTesting(false)
                }
                
                TextEditor(text: $content)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .scrollContentBackground(.hidden)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .accessibilityLabel("Delete Note")
                    
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(isSaveDisabled)
                }
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
    
    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
    let folder = Folder(name: "School")
    let note = Note(title: "SwiftData Notes", content: "Learn about @Model and @Query", folder: folder)
    return NavigationStack {
        EditNoteView(note: note)
    }
    .modelContainer(for: [Folder.self, Note.self], inMemory: true)
}
