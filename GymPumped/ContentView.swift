//
//  ContentView.swift
//  GymPumped
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        Group {
            if authService.loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2.0)
            } else if authService.currentUser != nil {
                MainTabView()
            } else {
                AuthView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService())
}
