//
//  DailyRewards.swift
//  BananaClicker V2.0
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import SwiftData

/// Daily login rewards tracker
@Model
final class DailyRewardProgress {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var currentStreak: Int
    var longestStreak: Int
    var lastClaimDate: Date?
    var totalRewardsClaimed: Int
    var missedDays: Int

    init(userId: UUID) {
        self.id = UUID()
        self.userId = userId
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastClaimDate = nil
        self.totalRewardsClaimed = 0
        self.missedDays = 0
    }

    /// Check if reward is available today
    func canClaimToday() -> Bool {
        guard let lastClaim = lastClaimDate else { return true }

        let calendar = Calendar.current
        return !calendar.isDate(lastClaim, inSameDayAs: Date())
    }

    /// Claim today's reward
    func claimReward() -> DailyReward? {
        guard canClaimToday() else { return nil }

        // Check if streak continues
        if let lastClaim = lastClaimDate {
            let calendar = Calendar.current
            let daysSinceLastClaim = calendar.dateComponents([.day], from: lastClaim, to: Date()).day ?? 0

            if daysSinceLastClaim == 1 {
                // Streak continues
                currentStreak += 1
            } else if daysSinceLastClaim > 1 {
                // Streak broken
                missedDays += daysSinceLastClaim - 1
                currentStreak = 1
            }
        } else {
            // First claim
            currentStreak = 1
        }

        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }

        lastClaimDate = Date()
        totalRewardsClaimed += 1

        // Return reward for current day
        let dayInCycle = (currentStreak - 1) % 7
        return DailyReward.rewards[dayInCycle]
    }

    /// Get current day's reward (without claiming)
    func getTodayReward() -> DailyReward {
        let dayInCycle = currentStreak % 7
        return DailyReward.rewards[dayInCycle]
    }
}

/// Daily reward definition
struct DailyReward {
    let day: Int
    let clicks: Int
    let gems: Int
    let goldenBananas: Int
    let specialReward: SpecialReward?

    enum SpecialReward {
        case skin(String)
        case powerUp(String)
        case multiplier(Double, TimeInterval)
    }

    static let rewards: [DailyReward] = [
        DailyReward(
            day: 1,
            clicks: 100,
            gems: 5,
            goldenBananas: 0,
            specialReward: nil
        ),
        DailyReward(
            day: 2,
            clicks: 250,
            gems: 10,
            goldenBananas: 0,
            specialReward: nil
        ),
        DailyReward(
            day: 3,
            clicks: 500,
            gems: 15,
            goldenBananas: 0,
            specialReward: .skin("red_banana")
        ),
        DailyReward(
            day: 4,
            clicks: 1000,
            gems: 25,
            goldenBananas: 0,
            specialReward: nil
        ),
        DailyReward(
            day: 5,
            clicks: 2000,
            gems: 50,
            goldenBananas: 1,
            specialReward: nil
        ),
        DailyReward(
            day: 6,
            clicks: 5000,
            gems: 75,
            goldenBananas: 1,
            specialReward: .skin("rainbow_banana")
        ),
        DailyReward(
            day: 7,
            clicks: 10000,
            gems: 100,
            goldenBananas: 2,
            specialReward: .multiplier(2.0, 3600) // 2x for 1 hour
        )
    ]
}

/// Comeback bonus for returning players
struct ComebackBonus {
    let daysAway: Int
    let clicks: Int
    let gems: Int
    let message: String

    static func calculate(daysAway: Int) -> ComebackBonus? {
        switch daysAway {
        case 3..<7:
            return ComebackBonus(
                daysAway: daysAway,
                clicks: 5000,
                gems: 50,
                message: "Welcome back! Here's a little something for returning."
            )
        case 7..<14:
            return ComebackBonus(
                daysAway: daysAway,
                clicks: 15000,
                gems: 150,
                message: "We missed you! Here's a comeback bonus."
            )
        case 14..<30:
            return ComebackBonus(
                daysAway: daysAway,
                clicks: 50000,
                gems: 500,
                message: "Welcome back, champion! Big rewards await."
            )
        case 30...:
            return ComebackBonus(
                daysAway: daysAway,
                clicks: 100000,
                gems: 1000,
                message: "The legend returns! Massive comeback bonus!"
            )
        default:
            return nil
        }
    }
}
