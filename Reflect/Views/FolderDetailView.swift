//
//  FolderDetailView.swift
//  Reflect
//

import SwiftUI
import SwiftData

struct FolderDetailView: View {
    @Bindable var folder: Folder
    
    var body: some View {
        Text("Notes in \(folder.name)")
            .navigationTitle(folder.name)
            .navigationBarTitleDisplayMode(.inline)
    }
}
