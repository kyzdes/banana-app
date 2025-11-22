//
//  Friend.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation

/// Represents a friend relationship
struct Friend: Codable, Identifiable, Sendable {
    let id: UUID
    let userId: UUID
    let nickname: String
    let totalClicks: Int
    let rank: Int
    let avatarEmoji: String
    var status: FriendStatus
    let addedAt: Date

    init(
        id: UUID = UUID(),
        userId: UUID,
        nickname: String,
        totalClicks: Int,
        rank: Int,
        avatarEmoji: String = "🍌",
        status: FriendStatus = .accepted,
        addedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.nickname = nickname
        self.totalClicks = totalClicks
        self.rank = rank
        self.avatarEmoji = avatarEmoji
        self.status = status
        self.addedAt = addedAt
    }
}

/// Friend relationship status
enum FriendStatus: String, Codable, Sendable {
    case pending
    case accepted
    case blocked
}

/// Friend request
struct FriendRequest: Codable, Identifiable, Sendable {
    let id: UUID
    let fromUserId: UUID
    let fromNickname: String
    let fromAvatarEmoji: String
    let fromTotalClicks: Int
    let sentAt: Date
}

// MARK: - Mock Data for Previews
extension Friend {
    static let previewData: [Friend] = [
        Friend(userId: UUID(), nickname: "click_master", totalClicks: 2_345_678, rank: 45, avatarEmoji: "🚀"),
        Friend(userId: UUID(), nickname: "banana_pro", totalClicks: 1_876_543, rank: 89, avatarEmoji: "💪"),
        Friend(userId: UUID(), nickname: "speed_demon", totalClicks: 1_543_210, rank: 123, avatarEmoji: "⚡️"),
        Friend(userId: UUID(), nickname: "casual_clicker", totalClicks: 876_543, rank: 456, avatarEmoji: "😎"),
        Friend(userId: UUID(), nickname: "beginner_banana", totalClicks: 123_456, rank: 1234, avatarEmoji: "🌱")
    ]
}
