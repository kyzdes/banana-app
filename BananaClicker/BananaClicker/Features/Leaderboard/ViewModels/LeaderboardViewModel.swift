//
//  LeaderboardViewModel.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import OSLog
import Observation

@Observable
@MainActor
final class LeaderboardViewModel {
    // MARK: - Properties

    var entries: [LeaderboardEntry] = []
    var currentUserEntry: LeaderboardEntry?
    var totalPlayers: Int = 0
    var selectedType: LeaderboardType = .global
    var isLoading: Bool = false
    var error: Error?

    private let fetchLeaderboardUseCase = FetchLeaderboardUseCase()
    private let logger = Logger(subsystem: "com.yourcompany.bananaclicker", category: "LeaderboardViewModel")

    // Auto-refresh timer
    private var refreshTimer: Timer?

    // MARK: - Initialization

    init() {
        Task {
            await loadLeaderboard()
        }
        startAutoRefresh()
    }

    deinit {
        refreshTimer?.invalidate()
    }

    // MARK: - Public Methods

    /// Load leaderboard data
    func loadLeaderboard(forceRefresh: Bool = false) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response = try await fetchLeaderboardUseCase.execute(
                type: selectedType,
                forceRefresh: forceRefresh
            )

            entries = response.entries
            currentUserEntry = response.currentUserEntry
            totalPlayers = response.totalPlayers

            logger.info("Leaderboard loaded: \(entries.count) entries")
        } catch {
            logger.error("Failed to load leaderboard: \(error.localizedDescription)")
            self.error = error
        }
    }

    /// Change leaderboard type
    func changeType(_ type: LeaderboardType) async {
        guard type != selectedType else { return }

        selectedType = type
        await loadLeaderboard(forceRefresh: true)
    }

    /// Refresh leaderboard
    func refresh() async {
        await loadLeaderboard(forceRefresh: true)
    }

    // MARK: - Private Methods

    private func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.Leaderboard.autoRefreshInterval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.loadLeaderboard(forceRefresh: false)
            }
        }
    }

    // MARK: - Computed Properties

    var hasData: Bool {
        !entries.isEmpty
    }

    var isEmpty: Bool {
        entries.isEmpty && !isLoading
    }
}
