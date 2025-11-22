//
//  LeaderboardEntry.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation

/// Represents a single entry in the leaderboard
struct LeaderboardEntry: Codable, Identifiable, Sendable {
    let id: UUID
    let rank: Int
    let userId: UUID
    let nickname: String
    let totalClicks: Int
    let clicksThisWeek: Int
    let avatarEmoji: String
    let isFriend: Bool
    let isCurrentUser: Bool

    init(
        id: UUID = UUID(),
        rank: Int,
        userId: UUID,
        nickname: String,
        totalClicks: Int,
        clicksThisWeek: Int,
        avatarEmoji: String = "🍌",
        isFriend: Bool = false,
        isCurrentUser: Bool = false
    ) {
        self.id = id
        self.rank = rank
        self.userId = userId
        self.nickname = nickname
        self.totalClicks = totalClicks
        self.clicksThisWeek = clicksThisWeek
        self.avatarEmoji = avatarEmoji
        self.isFriend = isFriend
        self.isCurrentUser = isCurrentUser
    }

    /// Returns medal emoji for top 3 ranks
    var medalEmoji: String? {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return nil
        }
    }

    /// Formatted click count with proper separators
    var formattedClicks: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: totalClicks)) ?? "\(totalClicks)"
    }
}

/// Response from leaderboard API endpoint
struct LeaderboardResponse: Codable, Sendable {
    let entries: [LeaderboardEntry]
    let currentUserEntry: LeaderboardEntry
    let totalPlayers: Int
    let lastUpdated: Date
}

/// Type of leaderboard to display
enum LeaderboardType: String, CaseIterable, Sendable {
    case global = "Global"
    case friends = "Friends"
    case weekly = "Weekly"
    case regional = "Regional"

    var icon: String {
        switch self {
        case .global: return "globe"
        case .friends: return "person.2.fill"
        case .weekly: return "calendar"
        case .regional: return "location.fill"
        }
    }
}

// MARK: - Mock Data for Previews
extension LeaderboardEntry {
    static let previewData: [LeaderboardEntry] = [
        LeaderboardEntry(rank: 1, userId: UUID(), nickname: "banana_king", totalClicks: 12_345_678, clicksThisWeek: 123_456, avatarEmoji: "👑", isFriend: false),
        LeaderboardEntry(rank: 2, userId: UUID(), nickname: "click_master", totalClicks: 10_234_567, clicksThisWeek: 102_345, avatarEmoji: "🚀", isFriend: true),
        LeaderboardEntry(rank: 3, userId: UUID(), nickname: "speedclicker", totalClicks: 9_876_543, clicksThisWeek: 98_765, avatarEmoji: "⚡️", isFriend: false),
        LeaderboardEntry(rank: 4, userId: UUID(), nickname: "pro_gamer", totalClicks: 8_765_432, clicksThisWeek: 87_654, avatarEmoji: "🎮", isFriend: true),
        LeaderboardEntry(rank: 5, userId: UUID(), nickname: "ninja_clicker", totalClicks: 7_654_321, clicksThisWeek: 76_543, avatarEmoji: "🥷", isFriend: false),
        LeaderboardEntry(rank: 142, userId: UUID(), nickname: "you", totalClicks: 1_234_567, clicksThisWeek: 12_345, avatarEmoji: "🍌", isFriend: false, isCurrentUser: true)
    ]
}
