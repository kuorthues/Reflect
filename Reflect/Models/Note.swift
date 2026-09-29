//
//  Note.swift
//  Reflect
//

import Foundation
import SwiftData

@Model
final class Note {
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var folder: Folder?
    
    init(
        title: String,
        content: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        folder: Folder? = nil
    ) {
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.folder = folder
    }
}
