//
//  FriendsViewModel.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import OSLog
import Observation

@Observable
@MainActor
final class FriendsViewModel {
    // MARK: - Properties

    var friends: [Friend] = []
    var isLoading: Bool = false
    var error: Error?
    var showingAddFriend: Bool = false

    private let friendsRepository = FriendsRepository.shared
    private let addFriendUseCase = AddFriendUseCase()
    private let logger = Logger(subsystem: "com.yourcompany.bananaclicker", category: "FriendsViewModel")

    // MARK: - Initialization

    init() {
        Task {
            await loadFriends()
        }
    }

    // MARK: - Public Methods

    /// Load friends list
    func loadFriends() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            friends = try await friendsRepository.fetchFriends()
            logger.info("Loaded \(friends.count) friends")
        } catch {
            logger.error("Failed to load friends: \(error.localizedDescription)")
            self.error = error
        }
    }

    /// Add friend by nickname
    func addFriend(nickname: String) async -> Bool {
        do {
            let friend = try await addFriendUseCase.execute(nickname: nickname)
            friends.append(friend)
            logger.info("Friend added: \(friend.nickname)")
            return true
        } catch {
            logger.error("Failed to add friend: \(error.localizedDescription)")
            self.error = error
            return false
        }
    }

    /// Remove friend
    func removeFriend(_ friend: Friend) async {
        do {
            try await friendsRepository.removeFriend(id: friend.id)
            friends.removeAll { $0.id == friend.id }
            logger.info("Friend removed: \(friend.nickname)")
        } catch {
            logger.error("Failed to remove friend: \(error.localizedDescription)")
            self.error = error
        }
    }

    /// Refresh friends list
    func refresh() async {
        await loadFriends()
    }

    // MARK: - Computed Properties

    var hasData: Bool {
        !friends.isEmpty
    }

    var isEmpty: Bool {
        friends.isEmpty && !isLoading
    }

    var friendsCount: Int {
        friends.count
    }

    var canAddMoreFriends: Bool {
        friendsCount < Constants.Friends.maxFriends
    }
}
