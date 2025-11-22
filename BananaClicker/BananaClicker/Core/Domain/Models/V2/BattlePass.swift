//
//  BattlePass.swift
//  BananaClicker V2.0
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import SwiftData

/// Battle pass progression
@Model
final class BattlePassProgress {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var seasonId: String
    var level: Int
    var xp: Int
    var isPremium: Bool
    var claimedRewards: [Int] // tier numbers
    var startDate: Date
    var endDate: Date

    init(userId: UUID, seasonId: String) {
        self.id = UUID()
        self.userId = userId
        self.seasonId = seasonId
        self.level = 1
        self.xp = 0
        self.isPremium = false
        self.claimedRewards = []
        self.startDate = Date()
        self.endDate = Date().addingTimeInterval(60 * 24 * 3600) // 60 days
    }

    func xpForNextLevel() -> Int {
        return 1000 + (level * 100)
    }

    func addXP(_ amount: Int) {
        xp += amount

        while xp >= xpForNextLevel() && level < 50 {
            xp -= xpForNextLevel()
            level += 1
        }
    }

    func canClaimReward(tier: Int) -> Bool {
        level >= tier && !claimedRewards.contains(tier)
    }

    func claimReward(tier: Int) {
        if canClaimReward(tier: tier) {
            claimedRewards.append(tier)
        }
    }

    var isActive: Bool {
        Date() <= endDate
    }

    var daysRemaining: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: endDate).day ?? 0
        return max(0, days)
    }
}

/// Battle pass reward tier
struct BattlePassTier {
    let tier: Int
    let freeReward: Reward?
    let premiumReward: Reward?
    let xpRequired: Int

    struct Reward {
        let type: RewardType
        let amount: Int
        let special: String?

        enum RewardType {
            case clicks
            case gems
            case goldenBananas
            case skin
            case title
            case emote
        }
    }

    static func generateSeason() -> [BattlePassTier] {
        var tiers: [BattlePassTier] = []

        for tier in 1...50 {
            let xp = 1000 + ((tier - 1) * 100)

            let free: Reward?
            let premium: Reward?

            // Every tier has free reward
            if tier % 5 == 0 {
                free = Reward(type: .gems, amount: tier * 10, special: nil)
            } else {
                free = Reward(type: .clicks, amount: tier * 100, special: nil)
            }

            // Premium rewards are better
            switch tier {
            case 5:
                premium = Reward(type: .skin, amount: 1, special: "bp_skin_1")
            case 10:
                premium = Reward(type: .goldenBananas, amount: 5, special: nil)
            case 15:
                premium = Reward(type: .skin, amount: 1, special: "bp_skin_2")
            case 20:
                premium = Reward(type: .title, amount: 1, special: "Battle Master")
            case 25:
                premium = Reward(type: .skin, amount: 1, special: "bp_skin_3")
            case 30:
                premium = Reward(type: .goldenBananas, amount: 10, special: nil)
            case 40:
                premium = Reward(type: .skin, amount: 1, special: "bp_skin_epic")
            case 50:
                premium = Reward(type: .skin, amount: 1, special: "bp_skin_legendary")
            default:
                if tier % 2 == 0 {
                    premium = Reward(type: .gems, amount: tier * 20, special: nil)
                } else {
                    premium = Reward(type: .clicks, amount: tier * 500, special: nil)
                }
            }

            tiers.append(BattlePassTier(
                tier: tier,
                freeReward: free,
                premiumReward: premium,
                xpRequired: xp
            ))
        }

        return tiers
    }
}
