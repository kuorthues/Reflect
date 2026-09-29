//
//  PaperTheme.swift
//  Reflect
//

import SwiftUI

enum PaperTheme {
    /// Main warm paper background color (#FFF6D2)
    static let paper = Color(red: 255/255.0, green: 246/255.0, blue: 210/255.0)
    
    /// Neutral background outside paper areas
    static let screenBackground = Color(red: 250/255.0, green: 248/255.0, blue: 245/255.0)
    
    /// Near black for primary text and titles
    static let ink = Color(red: 0.12, green: 0.12, blue: 0.12)
    
    /// Dark gray for secondary text and small metadata
    static let inkSecondary = Color(red: 0.45, green: 0.43, blue: 0.40)
    
    /// Thin divider color (muted gray / faint ink)
    static let divider = Color(red: 0.12, green: 0.12, blue: 0.12).opacity(0.12)
    
    /// Subtle rectangular paper border
    static let paperBorder = Color(red: 0.12, green: 0.12, blue: 0.12).opacity(0.16)
    
    /// Input borders
    static let border = Color(red: 0.12, green: 0.12, blue: 0.12).opacity(0.25)
}
