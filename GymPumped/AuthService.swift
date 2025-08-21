//
//  AuthService.swift
//  GymPumped
//
//  Created by Jake Mair on 8/21/25.
//

import Foundation
import FirebaseAuth
import SwiftUI

class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var loading = true

    init() {
        Auth.auth().addStateDidChangeListener { auth, user in
            self.currentUser = user
            self.loading = false
        }
    }

    func signup(email: String, password: String, displayName: String) async throws {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let changeRequest = authResult.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()
    }

    func login(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func logout() async throws {
        try Auth.auth().signOut()
    }
}
