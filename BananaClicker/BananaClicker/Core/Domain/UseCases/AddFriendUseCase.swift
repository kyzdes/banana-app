//
//  AddFriendUseCase.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import OSLog

/// Use case for adding friends
final class AddFriendUseCase {
    private let friendsRepository = FriendsRepository.shared
    private let userRepository = UserRepository.shared
    private let hapticManager = HapticManager.shared
    private let logger = Logger(subsystem: "com.yourcompany.bananaclicker", category: "AddFriend")

    func execute(nickname: String) async throws -> Friend {
        // Validate nickname format
        guard User.isValidNickname(nickname) else {
            logger.error("Invalid nickname format: \(nickname)")
            hapticManager.playErrorHaptic()
            throw AddFriendError.invalidNickname
        }

        // Check if user exists
        do {
            let user = try await userRepository.searchUser(nickname: nickname)
            logger.info("Found user: \(user.nickname)")
        } catch {
            logger.error("User not found: \(nickname)")
            hapticManager.playErrorHaptic()
            throw AddFriendError.userNotFound
        }

        // Add friend
        do {
            let friend = try await friendsRepository.addFriend(nickname: nickname)
            logger.info("Friend added successfully: \(friend.nickname)")
            hapticManager.playSuccessHaptic()
            return friend
        } catch {
            logger.error("Failed to add friend: \(error.localizedDescription)")
            hapticManager.playErrorHaptic()
            throw error
        }
    }
}

/// Errors related to adding friends
enum AddFriendError: LocalizedError {
    case invalidNickname
    case userNotFound
    case alreadyFriends
    case friendLimitReached

    var errorDescription: String? {
        switch self {
        case .invalidNickname:
            return "Invalid nickname format. Must be 3-20 alphanumeric characters."
        case .userNotFound:
            return "User not found. Please check the nickname."
        case .alreadyFriends:
            return "You are already friends with this user."
        case .friendLimitReached:
            return "Friend limit reached (max \(Constants.Friends.maxFriends))."
        }
    }
}
