//
//  PvP.swift
//  BananaClicker V2.0
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import SwiftData

/// PvP battle data
@Model
final class PvPStats {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var wins: Int
    var losses: Int
    var eloRating: Int
    var highestRating: Int
    var totalBattles: Int
    var winStreak: Int
    var longestWinStreak: Int

    init(userId: UUID) {
        self.id = UUID()
        self.userId = userId
        self.wins = 0
        self.losses = 0
        self.eloRating = 1000 // Starting rating
        self.highestRating = 1000
        self.totalBattles = 0
        self.winStreak = 0
        self.longestWinStreak = 0
    }

    var winRate: Double {
        guard totalBattles > 0 else { return 0 }
        return Double(wins) / Double(totalBattles)
    }

    func recordWin(opponentRating: Int) {
        wins += 1
        totalBattles += 1
        winStreak += 1

        if winStreak > longestWinStreak {
            longestWinStreak = winStreak
        }

        // Update ELO
        let expectedScore = 1.0 / (1.0 + pow(10.0, Double(opponentRating - eloRating) / 400.0))
        let newRating = eloRating + Int(32 * (1.0 - expectedScore))
        eloRating = newRating

        if eloRating > highestRating {
            highestRating = eloRating
        }
    }

    func recordLoss(opponentRating: Int) {
        losses += 1
        totalBattles += 1
        winStreak = 0

        // Update ELO
        let expectedScore = 1.0 / (1.0 + pow(10.0, Double(opponentRating - eloRating) / 400.0))
        let newRating = eloRating + Int(32 * (0.0 - expectedScore))
        eloRating = max(100, newRating) // Min rating is 100
    }
}

/// Active battle session
struct Battle: Identifiable, Codable {
    let id: UUID
    let player1: BattlePlayer
    let player2: BattlePlayer
    let duration: TimeInterval
    let mode: BattleMode
    var startTime: Date?
    var endTime: Date?
    var winner: UUID?
    var status: BattleStatus

    enum BattleMode: String, Codable {
        case quick = "Quick Match" // 30 seconds
        case standard = "Standard" // 60 seconds
        case marathon = "Marathon" // 120 seconds
    }

    enum BattleStatus: String, Codable {
        case waiting
        case active
        case finished
        case cancelled
    }

    struct BattlePlayer: Codable {
        let userId: UUID
        let nickname: String
        let avatarEmoji: String
        let eloRating: Int
        var clicks: Int
        var powerUpsUsed: [String]
    }

    var durationSeconds: Int {
        switch mode {
        case .quick: return 30
        case .standard: return 60
        case .marathon: return 120
        }
    }
}

/// Battle power-up
struct BattlePowerUp: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let effect: PowerUpEffect
    let duration: TimeInterval
    let cooldown: TimeInterval

    enum PowerUpEffect: Codable {
        case clickMultiplier(Double)
        case freezeOpponent(TimeInterval)
        case shield(TimeInterval)
        case autoClicks(Int, TimeInterval)
    }

    static let allPowerUps: [BattlePowerUp] = [
        BattlePowerUp(
            id: "frenzy",
            name: "Click Frenzy",
            description: "2x click power for 5 seconds",
            icon: "bolt.fill",
            effect: .clickMultiplier(2.0),
            duration: 5.0,
            cooldown: 15.0
        ),
        BattlePowerUp(
            id: "freeze",
            name: "Freeze",
            description: "Freeze opponent for 3 seconds",
            icon: "snowflake",
            effect: .freezeOpponent(3.0),
            duration: 3.0,
            cooldown: 30.0
        ),
        BattlePowerUp(
            id: "shield",
            name: "Shield",
            description: "Block opponent power-ups for 5 seconds",
            icon: "shield.fill",
            effect: .shield(5.0),
            duration: 5.0,
            cooldown: 25.0
        ),
        BattlePowerUp(
            id: "auto_click",
            name: "Auto-Blast",
            description: "10 automatic clicks per second for 3 seconds",
            icon: "sparkles",
            effect: .autoClicks(10, 3.0),
            duration: 3.0,
            cooldown: 20.0
        )
    ]
}
