//
//  LeaderboardRepository.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import OSLog

/// Repository for leaderboard data
@Observable
final class LeaderboardRepository: Sendable {
    static let shared = LeaderboardRepository()

    private let apiClient = APIClient.shared
    private let logger = Logger(subsystem: "com.yourcompany.bananaclicker", category: "LeaderboardRepository")

    // Cache
    private var cachedResponse: LeaderboardResponse?
    private var cacheTimestamp: Date?
    private let cacheTTL: TimeInterval = 300 // 5 minutes

    private init() {}

    /// Fetch global leaderboard
    func fetchGlobalLeaderboard(offset: Int = 0, limit: Int = 100, forceRefresh: Bool = false) async throws -> LeaderboardResponse {
        // Check cache
        if !forceRefresh,
           let cached = cachedResponse,
           let timestamp = cacheTimestamp,
           Date().timeIntervalSince(timestamp) < cacheTTL {
            logger.info("Returning cached leaderboard data")
            return cached
        }

        logger.info("Fetching global leaderboard (offset: \(offset), limit: \(limit))")
        let response: LeaderboardResponse = try await apiClient.request(
            endpoint: .globalLeaderboard(offset: offset, limit: limit)
        )

        // Update cache
        cachedResponse = response
        cacheTimestamp = Date()

        logger.info("Leaderboard fetched: \(response.entries.count) entries, \(response.totalPlayers) total players")
        return response
    }

    /// Fetch friends leaderboard
    func fetchFriendsLeaderboard() async throws -> LeaderboardResponse {
        logger.info("Fetching friends leaderboard")
        let response: LeaderboardResponse = try await apiClient.request(endpoint: .friendsLeaderboard)
        logger.info("Friends leaderboard fetched: \(response.entries.count) entries")
        return response
    }

    /// Fetch weekly leaderboard
    func fetchWeeklyLeaderboard() async throws -> LeaderboardResponse {
        logger.info("Fetching weekly leaderboard")
        let response: LeaderboardResponse = try await apiClient.request(endpoint: .weeklyLeaderboard)
        logger.info("Weekly leaderboard fetched: \(response.entries.count) entries")
        return response
    }

    /// Fetch regional leaderboard
    func fetchRegionalLeaderboard(region: String) async throws -> LeaderboardResponse {
        logger.info("Fetching regional leaderboard for \(region)")
        let response: LeaderboardResponse = try await apiClient.request(
            endpoint: .regionalLeaderboard(region: region)
        )
        logger.info("Regional leaderboard fetched: \(response.entries.count) entries")
        return response
    }

    /// Clear cache
    func clearCache() {
        logger.info("Clearing leaderboard cache")
        cachedResponse = nil
        cacheTimestamp = nil
    }
}
