//
//  ReflectApp.swift
//  Reflect
//

import SwiftUI
import SwiftData

@main
struct ReflectApp: App {
    var body: some Scene {
        WindowGroup {
            FolderListView()
                .tint(PaperTheme.ink)
        }
        .modelContainer(for: [Folder.self, Note.self])
    }
}
