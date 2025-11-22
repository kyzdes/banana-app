//
//  User.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation

/// Represents a user in the Banana Clicker app
struct User: Codable, Identifiable, Sendable {
    let id: UUID
    let appleUserId: String
    var nickname: String
    var totalClicks: Int
    var clicksThisWeek: Int
    var rank: Int
    var friendsCount: Int
    var createdAt: Date
    var lastActiveAt: Date
    var avatarEmoji: String

    init(
        id: UUID = UUID(),
        appleUserId: String,
        nickname: String,
        totalClicks: Int = 0,
        clicksThisWeek: Int = 0,
        rank: Int = 0,
        friendsCount: Int = 0,
        createdAt: Date = Date(),
        lastActiveAt: Date = Date(),
        avatarEmoji: String = "🍌"
    ) {
        self.id = id
        self.appleUserId = appleUserId
        self.nickname = nickname
        self.totalClicks = totalClicks
        self.clicksThisWeek = clicksThisWeek
        self.rank = rank
        self.friendsCount = friendsCount
        self.createdAt = createdAt
        self.lastActiveAt = lastActiveAt
        self.avatarEmoji = avatarEmoji
    }

    /// Validates nickname format (3-20 characters, alphanumeric + underscore)
    static func isValidNickname(_ nickname: String) -> Bool {
        let pattern = "^[a-zA-Z0-9_]{3,20}$"
        return nickname.range(of: pattern, options: .regularExpression) != nil
    }
}

// MARK: - Mock Data for Previews
extension User {
    static let preview = User(
        id: UUID(),
        appleUserId: "000000.abc123.1234",
        nickname: "banana_king",
        totalClicks: 1_234_567,
        clicksThisWeek: 12_345,
        rank: 42,
        friendsCount: 15,
        createdAt: Date().addingTimeInterval(-86400 * 30),
        lastActiveAt: Date(),
        avatarEmoji: "🍌"
    )

    static let previewFriend = User(
        id: UUID(),
        appleUserId: "000000.def456.5678",
        nickname: "click_master",
        totalClicks: 2_345_678,
        clicksThisWeek: 23_456,
        rank: 12,
        friendsCount: 42,
        createdAt: Date().addingTimeInterval(-86400 * 60),
        lastActiveAt: Date().addingTimeInterval(-3600),
        avatarEmoji: "🚀"
    )
}
