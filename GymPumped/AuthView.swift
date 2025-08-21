//
//  AuthView.swift
//  GymPumped
//

import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject var authService: AuthService
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            // App Logo/Title
            Text("Pumped")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text(isLoginMode ? "Welcome Back" : "Create Account")
                .font(.headline)
                .foregroundColor(.gray)

            // Form Fields
            VStack(spacing: 15) {
                if !isLoginMode {
                    TextField("Display Name", text: $displayName)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)
            
            // Action Button
            Button(action: handleAuthAction) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(isLoginMode ? "Sign In" : "Sign Up")
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
            }
            .disabled(isLoading)
            .padding(.horizontal)
            
            // Toggle Login/Signup Mode
            Button(action: {
                withAnimation {
                    isLoginMode.toggle()
                    resetForm()
                }
            }) {
                Text(isLoginMode ? "Don't have an account? Sign up" : "Already have an account? Sign in")
                    .foregroundColor(.purple)
            }
        }
        .padding()
    }
    
    // Function to handle login or signup action
    private func handleAuthAction() {
        Task {
            isLoading = true
            errorMessage = ""
            do {
                if isLoginMode {
                    try await authService.login(email: email, password: password)
                } else {
                    guard !displayName.trimmingCharacters(in: .whitespaces).isEmpty else {
                        throw AuthError.displayNameRequired
                    }
                    try await authService.signup(email: email, password: password, displayName: displayName)
                }
            } catch let error as NSError {
                // Handle Firebase-specific errors
                errorMessage = error.localizedDescription
            } catch AuthError.displayNameRequired {
                errorMessage = "Display name is required for signup."
            }
            isLoading = false
        }
    }
    
    // Custom error type for display name
    enum AuthError: Error {
        case displayNameRequired
    }
    
    private func resetForm() {
        email = ""
        password = ""
        displayName = ""
        errorMessage = ""
    }
}

// A preview provider for the AuthView
#Preview {
    AuthView()
        .environmentObject(AuthService())
}
