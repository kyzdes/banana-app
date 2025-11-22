//
//  Achievement.swift
//  BananaClicker V2.0
//
//  Created by Claude on 2025-11-22.
//

import Foundation

/// Achievement definition
struct Achievement: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: Category
    let rarity: Rarity
    let requirement: Requirement
    let reward: Reward

    enum Category: String, Codable {
        case clicks
        case social
        case battle
        case collection
        case prestige
        case special
    }

    enum Rarity: String, Codable {
        case common
        case rare
        case epic
        case legendary
        case secret
    }

    struct Requirement: Codable {
        let type: RequirementType
        let target: Int

        enum RequirementType: String, Codable {
            case totalClicks
            case clicksInOneSession
            case pvpWins
            case friendsAdded
            case skinsCollected
            case prestigeLevel
            case guildLevel
            case questsCompleted
            case loginStreak
        }
    }

    struct Reward: Codable {
        let clicks: Int
        let gems: Int
        let goldenBananas: Int
        let title: String?
        let skin: String?
    }
}

// MARK: - Achievement Catalog
extension Achievement {
    static let allAchievements: [Achievement] = [
        // Clicks
        Achievement(
            id: "click_100",
            name: "First Steps",
            description: "Click 100 times",
            icon: "hand.tap",
            category: .clicks,
            rarity: .common,
            requirement: Requirement(type: .totalClicks, target: 100),
            reward: Reward(clicks: 50, gems: 5, goldenBananas: 0, title: nil, skin: nil)
        ),
        Achievement(
            id: "click_1000",
            name: "Getting Serious",
            description: "Click 1,000 times",
            icon: "hand.tap.fill",
            category: .clicks,
            rarity: .common,
            requirement: Requirement(type: .totalClicks, target: 1000),
            reward: Reward(clicks: 500, gems: 10, goldenBananas: 0, title: "Clicker", skin: nil)
        ),
        Achievement(
            id: "click_10000",
            name: "Dedicated",
            description: "Click 10,000 times",
            icon: "flame",
            category: .clicks,
            rarity: .rare,
            requirement: Requirement(type: .totalClicks, target: 10000),
            reward: Reward(clicks: 5000, gems: 50, goldenBananas: 1, title: "Dedicated", skin: "golden_banana")
        ),
        Achievement(
            id: "click_100000",
            name: "Click Master",
            description: "Click 100,000 times",
            icon: "flame.fill",
            category: .clicks,
            rarity: .epic,
            requirement: Requirement(type: .totalClicks, target: 100000),
            reward: Reward(clicks: 50000, gems: 200, goldenBananas: 5, title: "Click Master", skin: nil)
        ),
        Achievement(
            id: "click_1000000",
            name: "Click Legend",
            description: "Click 1,000,000 times",
            icon: "sparkles",
            category: .clicks,
            rarity: .legendary,
            requirement: Requirement(type: .totalClicks, target: 1000000),
            reward: Reward(clicks: 500000, gems: 1000, goldenBananas: 25, title: "Legend", skin: "rocket_banana")
        ),

        // Social
        Achievement(
            id: "friend_1",
            name: "Friendly",
            description: "Add your first friend",
            icon: "person.fill",
            category: .social,
            rarity: .common,
            requirement: Requirement(type: .friendsAdded, target: 1),
            reward: Reward(clicks: 100, gems: 5, goldenBananas: 0, title: nil, skin: nil)
        ),
        Achievement(
            id: "friend_10",
            name: "Social Butterfly",
            description: "Add 10 friends",
            icon: "person.2.fill",
            category: .social,
            rarity: .rare,
            requirement: Requirement(type: .friendsAdded, target: 10),
            reward: Reward(clicks: 5000, gems: 50, goldenBananas: 1, title: "Social", skin: nil)
        ),
        Achievement(
            id: "friend_50",
            name: "Popular",
            description: "Add 50 friends",
            icon: "person.3.fill",
            category: .social,
            rarity: .epic,
            requirement: Requirement(type: .friendsAdded, target: 50),
            reward: Reward(clicks: 25000, gems: 250, goldenBananas: 5, title: "Popular", skin: nil)
        ),

        // Battle
        Achievement(
            id: "pvp_1",
            name: "First Victory",
            description: "Win your first PvP battle",
            icon: "shield",
            category: .battle,
            rarity: .common,
            requirement: Requirement(type: .pvpWins, target: 1),
            reward: Reward(clicks: 500, gems: 10, goldenBananas: 0, title: nil, skin: nil)
        ),
        Achievement(
            id: "pvp_10",
            name: "Warrior",
            description: "Win 10 PvP battles",
            icon: "shield.fill",
            category: .battle,
            rarity: .rare,
            requirement: Requirement(type: .pvpWins, target: 10),
            reward: Reward(clicks: 5000, gems: 50, goldenBananas: 1, title: "Warrior", skin: nil)
        ),
        Achievement(
            id: "pvp_100",
            name: "Champion",
            description: "Win 100 PvP battles",
            icon: "crown",
            category: .battle,
            rarity: .epic,
            requirement: Requirement(type: .pvpWins, target: 100),
            reward: Reward(clicks: 50000, gems: 500, goldenBananas: 10, title: "Champion", skin: nil)
        ),
        Achievement(
            id: "pvp_1000",
            name: "Undefeated",
            description: "Win 1,000 PvP battles",
            icon: "crown.fill",
            category: .battle,
            rarity: .legendary,
            requirement: Requirement(type: .pvpWins, target: 1000),
            reward: Reward(clicks: 500000, gems: 5000, goldenBananas: 100, title: "Undefeated", skin: "crown_banana")
        ),

        // Collection
        Achievement(
            id: "skin_5",
            name: "Collector",
            description: "Collect 5 banana skins",
            icon: "square.grid.2x2",
            category: .collection,
            rarity: .common,
            requirement: Requirement(type: .skinsCollected, target: 5),
            reward: Reward(clicks: 1000, gems: 20, goldenBananas: 0, title: nil, skin: nil)
        ),
        Achievement(
            id: "skin_20",
            name: "Fashionista",
            description: "Collect 20 banana skins",
            icon: "square.grid.3x3",
            category: .collection,
            rarity: .rare,
            requirement: Requirement(type: .skinsCollected, target: 20),
            reward: Reward(clicks: 10000, gems: 100, goldenBananas: 2, title: "Fashionista", skin: nil)
        ),

        // Prestige
        Achievement(
            id: "prestige_1",
            name: "Rebirth",
            description: "Prestige for the first time",
            icon: "sparkle",
            category: .prestige,
            rarity: .epic,
            requirement: Requirement(type: .prestigeLevel, target: 1),
            reward: Reward(clicks: 0, gems: 100, goldenBananas: 10, title: "Reborn", skin: "fire_banana")
        ),
        Achievement(
            id: "prestige_10",
            name: "Transcendent",
            description: "Reach prestige level 10",
            icon: "sparkles",
            category: .prestige,
            rarity: .legendary,
            requirement: Requirement(type: .prestigeLevel, target: 10),
            reward: Reward(clicks: 0, gems: 1000, goldenBananas: 100, title: "Transcendent", skin: "god_banana")
        ),

        // Special
        Achievement(
            id: "streak_7",
            name: "Dedicated",
            description: "Login 7 days in a row",
            icon: "calendar",
            category: .special,
            rarity: .rare,
            requirement: Requirement(type: .loginStreak, target: 7),
            reward: Reward(clicks: 10000, gems: 100, goldenBananas: 2, title: "Dedicated", skin: nil)
        ),
        Achievement(
            id: "streak_30",
            name: "Devoted",
            description: "Login 30 days in a row",
            icon: "calendar.badge.clock",
            category: .special,
            rarity: .epic,
            requirement: Requirement(type: .loginStreak, target: 30),
            reward: Reward(clicks: 100000, gems: 1000, goldenBananas: 20, title: "Devoted", skin: "diamond_banana")
        )
    ]
}
