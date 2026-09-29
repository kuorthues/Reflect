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
            ZStack {
                PaperTheme.screenBackground
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Folder Name")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(PaperTheme.inkSecondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        
                        TextField("e.g. Journal, Work, Reading", text: $folderName)
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(PaperTheme.ink)
                            .padding(14)
                            .background(Color.white)
                            .overlay(
                                Rectangle()
                                    .stroke(PaperTheme.border, lineWidth: 1)
                            )
                            .focused($isFocused)
                    }
                    .padding(.top, 16)
                    
                    Text("Folders help you organize your notes into notebook sections.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(PaperTheme.inkSecondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(PaperTheme.inkSecondary)
                }
                .sharedBackgroundVisibility(.hidden)
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveFolder()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isSaveDisabled ? PaperTheme.inkSecondary.opacity(0.3) : PaperTheme.ink)
                    .disabled(isSaveDisabled)
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .onAppear {
                isFocused = true
            }
        }
        .tint(PaperTheme.ink)
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
