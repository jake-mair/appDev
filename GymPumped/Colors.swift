//
//  AppStyles.swift
//  GymPumped
//

import SwiftUI

extension Color {
    static let darkBackground = Color(red: 0.05, green: 0.05, blue: 0.05) // #0D0D0D
    static let cardBackground = Color(red: 0.1, green: 0.1, blue: 0.1) // #1A1A1A
    static let neonCyan = Color(red: 0.25, green: 0.78, blue: 0.98) // #40C7FA
    static let neonPurple = Color(red: 0.5, green: 0.25, blue: 0.75) // #8040BF
    static let neonPink = Color(red: 0.9, green: 0.3, blue: 0.6) // #E64DA8
}

extension LinearGradient {
    static let appHeader = LinearGradient(
        colors: [Color.neonPurple, Color.darkBackground],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [Color.neonPurple, Color.neonPink],
        startPoint: .leading,
        endPoint: .trailing
    )
}
