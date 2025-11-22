//
//  GameViewModel.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import SwiftData
import OSLog
import Observation

@Observable
@MainActor
final class GameViewModel {
    // MARK: - Properties

    var totalClicks: Int = 0
    var sessionClicks: Int = 0
    var clicksPerSecond: Double = 0
    var rank: Int = 0
    var isLoading: Bool = false
    var error: Error?

    // Animation state
    var bananaScale: CGFloat = 1.0
    var bananaRotation: Double = 0
    var showPlusOne: Bool = false
    var plusOneOffset: CGFloat = 0

    // Use Cases
    private let incrementClickUseCase = IncrementClickUseCase()
    private let clickRepository = ClickRepository.shared
    private let userRepository = UserRepository.shared

    private let logger = Logger(subsystem: "com.yourcompany.bananaclicker", category: "GameViewModel")

    // Current user
    var currentUser: User?

    // MARK: - Initialization

    init() {
        Task {
            await loadUserData()
        }
    }

    // MARK: - Public Methods

    /// Load user data and stats
    func loadUserData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Fetch current user
            currentUser = try await userRepository.fetchCurrentUser()
            totalClicks = currentUser?.totalClicks ?? 0
            rank = currentUser?.rank ?? 0

            // Fetch click stats
            let stats = try await clickRepository.fetchClickStats()
            clicksPerSecond = stats.averageCPS

            logger.info("User data loaded: \(totalClicks) clicks, rank #\(rank)")
        } catch {
            logger.error("Failed to load user data: \(error.localizedDescription)")
            self.error = error
        }
    }

    /// Handle banana click
    func handleClick(userId: UUID, modelContext: ModelContext) async {
        // Execute click use case
        let success = await incrementClickUseCase.execute(userId: userId, modelContext: modelContext)

        guard success else {
            logger.warning("Click rejected by rate limiter")
            return
        }

        // Update local state
        totalClicks += 1
        sessionClicks += 1

        // Update CPS
        updateClicksPerSecond()

        // Trigger animations
        await animateBananaClick()
    }

    /// Force sync pending clicks
    func syncClicks(userId: UUID) async {
        await incrementClickUseCase.forceSync(userId: userId)

        // Reload user data to get updated rank
        await loadUserData()
    }

    /// Refresh all data
    func refresh() async {
        await loadUserData()
    }

    // MARK: - Private Methods

    private func updateClicksPerSecond() {
        // Simple CPS calculation based on session
        // In real app, this would be more sophisticated
        clicksPerSecond = Double(sessionClicks) / max(1, Date().timeIntervalSince1970)
    }

    @MainActor
    private func animateBananaClick() async {
        // Scale animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            bananaScale = 1.1
        }

        // Random rotation
        let randomRotation = Double.random(in: -10...10)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            bananaRotation = randomRotation
        }

        // Plus one animation
        showPlusOne = true
        withAnimation(.easeOut(duration: 0.5)) {
            plusOneOffset = -50
        }

        // Reset animations
        try? await Task.sleep(for: .milliseconds(200))

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            bananaScale = 1.0
            bananaRotation = 0
        }

        try? await Task.sleep(for: .milliseconds(300))

        showPlusOne = false
        plusOneOffset = 0
    }

    // MARK: - Computed Properties

    var formattedClicks: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: totalClicks)) ?? "\(totalClicks)"
    }

    var formattedSessionClicks: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: sessionClicks)) ?? "\(sessionClicks)"
    }

    var formattedCPS: String {
        String(format: "%.1f", clicksPerSecond)
    }

    var pendingClicksCount: Int {
        incrementClickUseCase.pendingClicksCount
    }
}
