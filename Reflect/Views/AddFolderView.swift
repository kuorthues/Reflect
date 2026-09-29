//
//  AddFolderView.swift
//  Reflect
//

import SwiftUI
import SwiftData

struct AddFolderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var folderName: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Folder Name")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                TextField("Folder name", text: $folderName)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding(12)
                    .overlay(
                        Rectangle()
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                    .focused($isFocused)
                
                Text("Folders organize your notes into shelves on your bookshelf.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .padding(20)
            .background(Color(.systemBackground))
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveFolder()
                    }
                    .fontWeight(.semibold)
                    .disabled(isSaveDisabled)
                }
            }
            .onAppear {
                isFocused = true
            }
        }
    }
    
    private var isSaveDisabled: Bool {
        folderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveFolder() {
        let trimmedName = folderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newFolder = Folder(name: trimmedName)
        modelContext.insert(newFolder)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddFolderView()
        .modelContainer(for: [Folder.self, Note.self], inMemory: true)
}
