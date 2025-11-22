//
//  FriendsRepository.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import OSLog

/// Repository for managing friends
@Observable
final class FriendsRepository: Sendable {
    static let shared = FriendsRepository()

    private let apiClient = APIClient.shared
    private let logger = Logger(subsystem: "com.yourcompany.bananaclicker", category: "FriendsRepository")

    private init() {}

    /// Fetch list of friends
    func fetchFriends() async throws -> [Friend] {
        logger.info("Fetching friends list")

        struct FriendsResponse: Codable {
            let friends: [Friend]
        }

        let response: FriendsResponse = try await apiClient.request(endpoint: .friends)
        logger.info("Fetched \(response.friends.count) friends")
        return response.friends
    }

    /// Add a friend by nickname
    func addFriend(nickname: String) async throws -> Friend {
        logger.info("Adding friend: \(nickname)")

        struct AddFriendRequest: Encodable {
            let nickname: String
        }

        let request = AddFriendRequest(nickname: nickname)
        let friend: Friend = try await apiClient.request(
            endpoint: .addFriend,
            method: .post,
            body: request
        )

        logger.info("Friend added: \(friend.nickname)")
        return friend
    }

    /// Remove a friend
    func removeFriend(id: UUID) async throws {
        logger.info("Removing friend: \(id.uuidString)")
        try await apiClient.requestVoid(
            endpoint: .removeFriend(id: id),
            method: .delete
        )
        logger.info("Friend removed successfully")
    }

    /// Fetch friend requests
    func fetchFriendRequests() async throws -> [FriendRequest] {
        logger.info("Fetching friend requests")

        struct FriendRequestsResponse: Codable {
            let requests: [FriendRequest]
        }

        let response: FriendRequestsResponse = try await apiClient.request(endpoint: .friendRequests)
        logger.info("Fetched \(response.requests.count) friend requests")
        return response.requests
    }
}
