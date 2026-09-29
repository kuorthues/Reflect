//
//  AddNoteView.swift
//  Reflect
//

import SwiftUI
import SwiftData

struct AddNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let folder: Folder
    
    @State private var title: String = ""
    @State private var content: String = ""
    @FocusState private var isTitleFocused: Bool
    
    var body: some View {
        NavigationStack {
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
                        .focused($isTitleFocused)
                    
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
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(PaperTheme.inkSecondary)
                }
                .sharedBackgroundVisibility(.hidden)
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNote()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isSaveDisabled ? PaperTheme.inkSecondary.opacity(0.3) : PaperTheme.ink)
                    .disabled(isSaveDisabled)
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .onAppear {
                isTitleFocused = true
            }
        }
        .tint(PaperTheme.ink)
    }
    
    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveNote() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let newNote = Note(
            title: trimmedTitle,
            content: content,
            createdAt: Date(),
            updatedAt: Date(),
            folder: folder
        )
        modelContext.insert(newNote)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    let folder = Folder(name: "Sample Folder")
    return AddNoteView(folder: folder)
        .modelContainer(for: [Folder.self, Note.self], inMemory: true)
}
