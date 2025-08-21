//
//  Gradients.swift
//  GymPumped
//

import SwiftUI

extension LinearGradient {
    static let appBackground = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.15, green: 0.0, blue: 0.2), // Dark purple
            Color(red: 0.05, green: 0.05, blue: 0.05) // Very dark gray
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
}
