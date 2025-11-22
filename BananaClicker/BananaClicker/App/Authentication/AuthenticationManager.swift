//
//  AuthenticationManager.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import AuthenticationServices
import OSLog

/// Manages user authentication with Sign in with Apple
@Observable
@MainActor
final class AuthenticationManager: NSObject {
    static let shared = AuthenticationManager()

    private let logger = Logger(subsystem: "com.yourcompany.bananaclicker", category: "Authentication")
    private let apiClient = APIClient.shared

    var isAuthenticated: Bool = false
    var currentUser: User?
    var isLoading: Bool = false
    var error: Error?

    private override init() {
        super.init()
        Task {
            await checkAuthenticationState()
        }
    }

    // MARK: - Authentication

    /// Check if user is already authenticated
    func checkAuthenticationState() async {
        isLoading = true
        defer { isLoading = false }

        // Check if we have a token
        guard await KeychainManager.shared.getToken() != nil else {
            isAuthenticated = false
            logger.info("No authentication token found")
            return
        }

        // Try to fetch current user
        do {
            currentUser = try await UserRepository.shared.fetchCurrentUser()
            isAuthenticated = true
            logger.info("User authenticated: \(currentUser?.nickname ?? "unknown")")
        } catch {
            logger.error("Failed to fetch user: \(error.localizedDescription)")
            isAuthenticated = false
            await KeychainManager.shared.clearAll()
        }
    }

    /// Sign in with Apple
    func signInWithApple() async throws {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self

        // Start authorization
        controller.performRequests()
    }

    /// Handle successful authentication
    private func handleSuccessfulAuth(userId: String, identityToken: Data, fullName: PersonNameComponents?) async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Convert token to string
            guard let tokenString = String(data: identityToken, encoding: .utf8) else {
                throw AuthError.invalidToken
            }

            // Send to backend
            struct SignInRequest: Encodable {
                let appleUserId: String
                let identityToken: String
                let fullName: String?
            }

            struct SignInResponse: Decodable {
                let token: String
                let user: User
            }

            let fullNameString = [fullName?.givenName, fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")

            let request = SignInRequest(
                appleUserId: userId,
                identityToken: tokenString,
                fullName: fullNameString.isEmpty ? nil : fullNameString
            )

            let response: SignInResponse = try await apiClient.request(
                endpoint: .signInWithApple,
                method: .post,
                body: request
            )

            // Save token
            await KeychainManager.shared.saveToken(response.token)
            await KeychainManager.shared.saveUserId(userId)

            // Update state
            currentUser = response.user
            isAuthenticated = true

            logger.info("Sign in successful: \(response.user.nickname)")
        } catch {
            logger.error("Sign in failed: \(error.localizedDescription)")
            self.error = error
            isAuthenticated = false
        }
    }

    /// Logout
    func logout() async {
        do {
            try await apiClient.requestVoid(endpoint: .logout, method: .post)
        } catch {
            logger.error("Logout request failed: \(error.localizedDescription)")
        }

        await KeychainManager.shared.clearAll()
        currentUser = nil
        isAuthenticated = false
        logger.info("User logged out")
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthenticationManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = credential.identityToken else {
            logger.error("Failed to get credential or token")
            error = AuthError.invalidCredential
            return
        }

        Task {
            await handleSuccessfulAuth(
                userId: credential.user,
                identityToken: identityToken,
                fullName: credential.fullName
            )
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        logger.error("Authorization failed: \(error.localizedDescription)")
        self.error = error
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AuthenticationManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Get the first window scene
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            fatalError("No window available")
        }
        return window
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case invalidToken
    case invalidCredential
    case userCancelled

    var errorDescription: String? {
        switch self {
        case .invalidToken:
            return "Invalid authentication token"
        case .invalidCredential:
            return "Invalid authentication credential"
        case .userCancelled:
            return "Authentication cancelled by user"
        }
    }
}
