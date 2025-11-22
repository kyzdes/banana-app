//
//  LoginView.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI
import AuthenticationServices

/// Login screen with Sign in with Apple
struct LoginView: View {
    @Environment(AuthenticationManager.self) private var authManager

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient.bananaGradient
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Logo and title
                VStack(spacing: 20) {
                    Text("🍌")
                        .font(.system(size: 120))
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                    Text("Banana Clicker")
                        .font(.displayLarge)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5)

                    Text("Click your way to the top!")
                        .font(.headlineMedium)
                        .foregroundStyle(.white.opacity(0.9))
                }

                Spacer()

                // Sign in with Apple button
                VStack(spacing: 20) {
                    if authManager.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                    } else {
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            // Handled by AuthenticationManager
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .cornerRadius(12)

                        Text("Sign in to save your progress and compete with friends")
                            .font(.bodySmall)
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .alert("Error", isPresented: .constant(authManager.error != nil)) {
            Button("OK") {
                authManager.error = nil
            }
        } message: {
            if let error = authManager.error {
                Text(error.localizedDescription)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView()
        .environment(AuthenticationManager.shared)
}
