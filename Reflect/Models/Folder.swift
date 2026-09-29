//
//  Folder.swift
//  Reflect
//

import Foundation
import SwiftData

@Model
final class Folder {
    var name: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Note.folder)
    var notes: [Note] = []
    
    init(name: String, createdAt: Date = Date()) {
        self.name = name
        self.createdAt = createdAt
        self.notes = []
    }
}
