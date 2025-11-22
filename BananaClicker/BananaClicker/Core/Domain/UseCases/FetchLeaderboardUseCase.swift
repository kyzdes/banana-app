//
//  FetchLeaderboardUseCase.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import OSLog

/// Use case for fetching leaderboard data
final class FetchLeaderboardUseCase {
    private let leaderboardRepository = LeaderboardRepository.shared
    private let logger = Logger(subsystem: "com.yourcompany.bananaclicker", category: "FetchLeaderboard")

    func execute(type: LeaderboardType, forceRefresh: Bool = false) async throws -> LeaderboardResponse {
        logger.info("Fetching leaderboard: \(type.rawValue)")

        let response: LeaderboardResponse

        switch type {
        case .global:
            response = try await leaderboardRepository.fetchGlobalLeaderboard(forceRefresh: forceRefresh)

        case .friends:
            response = try await leaderboardRepository.fetchFriendsLeaderboard()

        case .weekly:
            response = try await leaderboardRepository.fetchWeeklyLeaderboard()

        case .regional:
            // Get user's region from locale
            let region = Locale.current.region?.identifier ?? "US"
            response = try await leaderboardRepository.fetchRegionalLeaderboard(region: region)
        }

        logger.info("Leaderboard fetched successfully: \(response.entries.count) entries")
        return response
    }

    func clearCache() {
        leaderboardRepository.clearCache()
    }
}
