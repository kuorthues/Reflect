//
//  PaperTheme.swift
//  Reflect
//

import SwiftUI

enum PaperTheme {
    // MARK: - Paper Palette (#FFF6D2)
    /// Main warm paper background color (#FFF6D2)
    static let paper = Color(red: 255/255.0, green: 246/255.0, blue: 210/255.0)
    static let paperBorder = Color(red: 0.15, green: 0.13, blue: 0.10).opacity(0.18)
    
    // MARK: - Bookshelf Palette
    /// Wall background behind the bookshelf
    static let shelfWall = Color(red: 248/255.0, green: 245/255.0, blue: 238/255.0)
    
    /// Bookshelf uprights and vertical framing
    static let shelfFrame = Color(red: 182/255.0, green: 164/255.0, blue: 138/255.0)
    
    /// Horizontal shelf board plank
    static let shelfPlank = Color(red: 206/255.0, green: 190/255.0, blue: 162/255.0)
    
    /// Top highlight line of shelf board
    static let shelfPlankTop = Color(red: 224/255.0, green: 210/255.0, blue: 184/255.0)
    
    /// Bottom shadow line under shelf board
    static let shelfPlankShadow = Color(red: 154/255.0, green: 136/255.0, blue: 110/255.0)
    
    /// Crisp wood border line
    static let shelfLine = Color(red: 138/255.0, green: 122/255.0, blue: 98/255.0)
    
    // MARK: - Decorative Book Spines
    static let bookPaper = Color(red: 255/255.0, green: 246/255.0, blue: 210/255.0) // #FFF6D2
    static let bookKraft = Color(red: 212/255.0, green: 188/255.0, blue: 154/255.0)
    static let bookLinen = Color(red: 188/255.0, green: 198/255.0, blue: 184/255.0)
    static let bookCharcoal = Color(red: 75/255.0, green: 70/255.0, blue: 66/255.0)
    static let bookTerracotta = Color(red: 192/255.0, green: 132/255.0, blue: 110/255.0)
    
    // MARK: - General Neutral Background
    static let screenBackground = Color(red: 250/255.0, green: 248/255.0, blue: 245/255.0)
    
    // MARK: - Typography & Ink
    static let ink = Color(red: 0.10, green: 0.10, blue: 0.10)
    static let inkSecondary = Color(red: 0.42, green: 0.40, blue: 0.38)
    static let divider = Color(red: 0.10, green: 0.10, blue: 0.10).opacity(0.12)
    static let border = Color(red: 0.10, green: 0.10, blue: 0.10).opacity(0.25)
}
