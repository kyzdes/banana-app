//
//  ClickRepository.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import SwiftData
import OSLog

/// Repository for managing clicks and sessions
@Observable
final class ClickRepository: Sendable {
    static let shared = ClickRepository()

    private let apiClient = APIClient.shared
    private let logger = Logger(subsystem: "com.yourcompany.bananaclicker", category: "ClickRepository")

    private init() {}

    /// Submit a batch of clicks to the server
    func submitClickBatch(_ batch: ClickBatch) async throws {
        logger.info("Submitting click batch with \(batch.clicks.count) clicks")
        try await apiClient.requestVoid(
            endpoint: .submitClicks,
            method: .post,
            body: batch
        )
        logger.info("Click batch submitted successfully")
    }

    /// Fetch user click statistics
    func fetchClickStats() async throws -> ClickStats {
        logger.info("Fetching click statistics")
        let stats: ClickStats = try await apiClient.request(endpoint: .clickStats)
        logger.info("Click stats fetched: \(stats.totalClicks) total clicks")
        return stats
    }
}

/// Click statistics response
struct ClickStats: Codable, Sendable {
    let totalClicks: Int
    let clicksToday: Int
    let clicksThisWeek: Int
    let clicksThisMonth: Int
    let averageCPS: Double
    let longestStreak: Int
    let totalPlayTime: TimeInterval
    let dailyHistory: [DailyClickCount]
}

/// Daily click count for charts
struct DailyClickCount: Codable, Identifiable, Sendable {
    let id: UUID
    let date: Date
    let clickCount: Int

    init(id: UUID = UUID(), date: Date, clickCount: Int) {
        self.id = id
        self.date = date
        self.clickCount = clickCount
    }
}
