//
//  ProfileView.swift
//  GymPumped
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Header
                if let user = authService.currentUser {
                    VStack(spacing: 10) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                        
                        Text(user.displayName ?? "Fitness Enthusiast")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.cyan, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text(user.email ?? "No Email")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                
                Spacer()
                
                // Sign Out Button
                Button(action: {
                    Task {
                        try await authService.logout()
                    }
                }) {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Profile")
            .background(Color.clear) // Makes the NavigationView background transparent
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthService())
}
