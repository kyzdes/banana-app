//
//  UserRepository.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import OSLog

/// Repository for user management
@Observable
final class UserRepository: Sendable {
    static let shared = UserRepository()

    private let apiClient = APIClient.shared
    private let logger = Logger(subsystem: "com.yourcompany.bananaclicker", category: "UserRepository")

    private init() {}

    /// Fetch current user profile
    func fetchCurrentUser() async throws -> User {
        logger.info("Fetching current user profile")
        let user: User = try await apiClient.request(endpoint: .currentUser)
        logger.info("User profile fetched: \(user.nickname)")
        return user
    }

    /// Update user profile
    func updateProfile(nickname: String? = nil, avatarEmoji: String? = nil) async throws -> User {
        logger.info("Updating user profile")

        struct UpdateRequest: Encodable {
            let nickname: String?
            let avatarEmoji: String?
        }

        let request = UpdateRequest(nickname: nickname, avatarEmoji: avatarEmoji)
        let user: User = try await apiClient.request(
            endpoint: .updateProfile,
            method: .put,
            body: request
        )

        logger.info("Profile updated successfully")
        return user
    }

    /// Search for user by nickname
    func searchUser(nickname: String) async throws -> User {
        logger.info("Searching for user: \(nickname)")
        let user: User = try await apiClient.request(endpoint: .searchUser(nickname: nickname))
        logger.info("User found: \(user.nickname)")
        return user
    }

    /// Delete user account
    func deleteAccount() async throws {
        logger.warning("Deleting user account")
        try await apiClient.requestVoid(endpoint: .deleteAccount, method: .delete)
        logger.info("Account deleted successfully")
    }
}
