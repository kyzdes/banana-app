//
//  Endpoints.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation

/// API Endpoints
enum Endpoint {
    // Authentication
    case signInWithApple
    case refreshToken
    case logout

    // User
    case currentUser
    case updateProfile
    case deleteAccount
    case searchUser(nickname: String)

    // Clicks
    case submitClicks
    case clickStats

    // Leaderboard
    case globalLeaderboard(offset: Int, limit: Int)
    case friendsLeaderboard
    case weeklyLeaderboard
    case regionalLeaderboard(region: String)

    // Friends
    case friends
    case addFriend
    case removeFriend(id: UUID)
    case friendRequests

    // Game Center
    case syncGameKit

    var path: String {
        switch self {
        // Authentication
        case .signInWithApple:
            return "auth/apple"
        case .refreshToken:
            return "auth/refresh"
        case .logout:
            return "auth/logout"

        // User
        case .currentUser:
            return "user/me"
        case .updateProfile:
            return "user/me"
        case .deleteAccount:
            return "user/me"
        case .searchUser(let nickname):
            return "user/\(nickname)"

        // Clicks
        case .submitClicks:
            return "clicks"
        case .clickStats:
            return "clicks/stats"

        // Leaderboard
        case .globalLeaderboard(let offset, let limit):
            return "leaderboard/global?offset=\(offset)&limit=\(limit)"
        case .friendsLeaderboard:
            return "leaderboard/friends"
        case .weeklyLeaderboard:
            return "leaderboard/weekly"
        case .regionalLeaderboard(let region):
            return "leaderboard/regional?region=\(region)"

        // Friends
        case .friends:
            return "friends"
        case .addFriend:
            return "friends/add"
        case .removeFriend(let id):
            return "friends/\(id.uuidString)"
        case .friendRequests:
            return "friends/requests"

        // Game Center
        case .syncGameKit:
            return "gamekit/sync"
        }
    }
}
