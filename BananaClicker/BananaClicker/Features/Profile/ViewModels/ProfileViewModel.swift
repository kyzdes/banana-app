//
//  ProfileViewModel.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import OSLog
import Observation

@Observable
@MainActor
final class ProfileViewModel {
    // MARK: - Properties

    var user: User?
    var clickStats: ClickStats?
    var isLoading: Bool = false
    var error: Error?

    // Settings
    var hapticsEnabled: Bool {
        get { HapticManager.shared.isEnabled }
        set { HapticManager.shared.isEnabled = newValue }
    }

    var soundEnabled: Bool {
        get { SoundManager.shared.isEnabled }
        set { SoundManager.shared.isEnabled = newValue }
    }

    private let userRepository = UserRepository.shared
    private let clickRepository = ClickRepository.shared
    private let logger = Logger(subsystem: "com.yourcompany.bananaclicker", category: "ProfileViewModel")

    // MARK: - Initialization

    init() {
        Task {
            await loadProfile()
        }
    }

    // MARK: - Public Methods

    /// Load user profile and stats
    func loadProfile() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            async let userFetch = userRepository.fetchCurrentUser()
            async let statsFetch = clickRepository.fetchClickStats()

            user = try await userFetch
            clickStats = try await statsFetch

            logger.info("Profile loaded: \(user?.nickname ?? "unknown")")
        } catch {
            logger.error("Failed to load profile: \(error.localizedDescription)")
            self.error = error
        }
    }

    /// Update nickname
    func updateNickname(_ nickname: String) async -> Bool {
        guard User.isValidNickname(nickname) else {
            logger.error("Invalid nickname: \(nickname)")
            return false
        }

        do {
            user = try await userRepository.updateProfile(nickname: nickname)
            logger.info("Nickname updated: \(nickname)")
            return true
        } catch {
            logger.error("Failed to update nickname: \(error.localizedDescription)")
            self.error = error
            return false
        }
    }

    /// Update avatar emoji
    func updateAvatar(_ emoji: String) async -> Bool {
        do {
            user = try await userRepository.updateProfile(avatarEmoji: emoji)
            logger.info("Avatar updated: \(emoji)")
            return true
        } catch {
            logger.error("Failed to update avatar: \(error.localizedDescription)")
            self.error = error
            return false
        }
    }

    /// Logout user
    func logout() async {
        await KeychainManager.shared.clearAll()
        logger.info("User logged out")
    }

    /// Delete account
    func deleteAccount() async -> Bool {
        do {
            try await userRepository.deleteAccount()
            await KeychainManager.shared.clearAll()
            logger.warning("Account deleted")
            return true
        } catch {
            logger.error("Failed to delete account: \(error.localizedDescription)")
            self.error = error
            return false
        }
    }

    /// Refresh profile
    func refresh() async {
        await loadProfile()
    }

    // MARK: - Computed Properties

    var formattedJoinDate: String {
        guard let user = user else { return "Unknown" }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: user.createdAt)
    }

    var formattedLastActive: String {
        guard let user = user else { return "Unknown" }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: user.lastActiveAt, relativeTo: Date())
    }

    var formattedTotalPlayTime: String {
        guard let stats = clickStats else { return "0h 0m" }

        let hours = Int(stats.totalPlayTime) / 3600
        let minutes = (Int(stats.totalPlayTime) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}
