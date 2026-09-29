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
        ZStack {
            PaperTheme.paper
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                TextField("Title", text: $title, axis: .vertical)
                    .font(.system(.title2, design: .serif).weight(.bold))
                    .foregroundStyle(PaperTheme.ink)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                
                Rectangle()
                    .fill(PaperTheme.divider)
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                
                TextEditor(text: $content)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(PaperTheme.ink)
                    .lineSpacing(6)
                    .scrollContentBackground(.hidden)
                    .background(PaperTheme.paper)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Rectangle()
                    .fill(PaperTheme.divider)
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                
                HStack {
                    Text("Updated \(note.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(PaperTheme.inkSecondary)
                    
                    Spacer()
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Text("Delete Note")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.red.opacity(0.85))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(PaperTheme.paper)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isSaveDisabled ? PaperTheme.inkSecondary.opacity(0.3) : PaperTheme.ink)
                .disabled(isSaveDisabled)
            }
            .sharedBackgroundVisibility(.hidden)
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
        .tint(PaperTheme.ink)
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
    let folder = Folder(name: "Work")
    let note = Note(title: "Meeting Notes", content: "Discuss project status and next steps.", folder: folder)
    return NavigationStack {
        EditNoteView(note: note)
    }
    .modelContainer(for: [Folder.self, Note.self], inMemory: true)
}
