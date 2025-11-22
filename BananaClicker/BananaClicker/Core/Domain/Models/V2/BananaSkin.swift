//
//  BananaSkin.swift
//  BananaClicker V2.0
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import SwiftUI

/// Player's skin collection
struct SkinCollection: Codable {
    var ownedSkinIds: [String]
    var equippedSkinId: String

    init() {
        self.ownedSkinIds = ["classic"] // Everyone starts with classic
        self.equippedSkinId = "classic"
    }

    mutating func unlockSkin(_ skinId: String) {
        if !ownedSkinIds.contains(skinId) {
            ownedSkinIds.append(skinId)
        }
    }

    mutating func equipSkin(_ skinId: String) {
        if ownedSkinIds.contains(skinId) {
            equippedSkinId = skinId
        }
    }

    func owns(_ skinId: String) -> Bool {
        ownedSkinIds.contains(skinId)
    }
}

/// Banana skin definition
struct BananaSkin: Identifiable, Codable {
    let id: String
    let name: String
    let emoji: String
    let rarity: Rarity
    let unlockMethod: UnlockMethod
    let description: String
    let particleEffect: String?
    let animationType: AnimationType

    enum Rarity: String, Codable, CaseIterable {
        case common = "Common"
        case rare = "Rare"
        case epic = "Epic"
        case legendary = "Legendary"
        case mythic = "Mythic"

        var color: Color {
            switch self {
            case .common: return .gray
            case .rare: return .blue
            case .epic: return .purple
            case .legendary: return .orange
            case .mythic: return Color(hex: "#FFD700") // Gold
            }
        }
    }

    enum UnlockMethod: Codable {
        case starter
        case purchase(Int) // cost in clicks
        case achievement(String)
        case prestige(Int) // prestige level required
        case quest(String)
        case seasonal(String)
        case premium // IAP only
    }

    enum AnimationType: String, Codable {
        case none
        case pulse
        case rotate
        case bounce
        case sparkle
        case rainbow
        case fire
        case ice
        case lightning
    }
}

// MARK: - Skins Catalog
extension BananaSkin {
    static let allSkins: [BananaSkin] = [
        // Common (Free/Easy to get)
        BananaSkin(
            id: "classic",
            name: "Classic Banana",
            emoji: "🍌",
            rarity: .common,
            unlockMethod: .starter,
            description: "The original. The legend.",
            particleEffect: nil,
            animationType: .none
        ),
        BananaSkin(
            id: "red_banana",
            name: "Red Banana",
            emoji: "🔴🍌",
            rarity: .common,
            unlockMethod: .purchase(1000),
            description: "A rare red variety",
            particleEffect: nil,
            animationType: .pulse
        ),
        BananaSkin(
            id: "green_banana",
            name: "Green Banana",
            emoji: "🟢🍌",
            rarity: .common,
            unlockMethod: .purchase(1000),
            description: "Not quite ripe yet",
            particleEffect: nil,
            animationType: .pulse
        ),
        BananaSkin(
            id: "blue_banana",
            name: "Blue Banana",
            emoji: "🔵🍌",
            rarity: .common,
            unlockMethod: .purchase(1000),
            description: "Feeling a bit blue",
            particleEffect: nil,
            animationType: .pulse
        ),

        // Rare
        BananaSkin(
            id: "golden_banana",
            name: "Golden Banana",
            emoji: "🏆",
            rarity: .rare,
            unlockMethod: .achievement("click_10000"),
            description: "Worth its weight in gold",
            particleEffect: "sparkle",
            animationType: .sparkle
        ),
        BananaSkin(
            id: "rainbow_banana",
            name: "Rainbow Banana",
            emoji: "🌈",
            rarity: .rare,
            unlockMethod: .purchase(50000),
            description: "Taste the rainbow",
            particleEffect: "rainbow",
            animationType: .rainbow
        ),
        BananaSkin(
            id: "cosmic_banana",
            name: "Cosmic Banana",
            emoji: "✨",
            rarity: .rare,
            unlockMethod: .purchase(100000),
            description: "From outer space",
            particleEffect: "stars",
            animationType: .sparkle
        ),

        // Epic
        BananaSkin(
            id: "fire_banana",
            name: "Fire Banana",
            emoji: "🔥",
            rarity: .epic,
            unlockMethod: .prestige(1),
            description: "This banana is on fire!",
            particleEffect: "fire",
            animationType: .fire
        ),
        BananaSkin(
            id: "ice_banana",
            name: "Ice Banana",
            emoji: "❄️",
            rarity: .epic,
            unlockMethod: .prestige(1),
            description: "Cool as ice",
            particleEffect: "snowflakes",
            animationType: .ice
        ),
        BananaSkin(
            id: "lightning_banana",
            name: "Lightning Banana",
            emoji: "⚡️",
            rarity: .epic,
            unlockMethod: .prestige(2),
            description: "Electrifying performance",
            particleEffect: "lightning",
            animationType: .lightning
        ),
        BananaSkin(
            id: "diamond_banana",
            name: "Diamond Banana",
            emoji: "💎",
            rarity: .epic,
            unlockMethod: .purchase(1000000),
            description: "A girl's best friend",
            particleEffect: "sparkle",
            animationType: .sparkle
        ),

        // Legendary
        BananaSkin(
            id: "crown_banana",
            name: "Royal Banana",
            emoji: "👑",
            rarity: .legendary,
            unlockMethod: .prestige(5),
            description: "Fit for a king",
            particleEffect: "crown_sparkles",
            animationType: .bounce
        ),
        BananaSkin(
            id: "rocket_banana",
            name: "Rocket Banana",
            emoji: "🚀",
            rarity: .legendary,
            unlockMethod: .achievement("click_1000000"),
            description: "To the moon!",
            particleEffect: "rocket_trail",
            animationType: .bounce
        ),
        BananaSkin(
            id: "alien_banana",
            name: "Alien Banana",
            emoji: "👽",
            rarity: .legendary,
            unlockMethod: .prestige(10),
            description: "Not from this world",
            particleEffect: "alien_glow",
            animationType: .sparkle
        ),

        // Mythic
        BananaSkin(
            id: "god_banana",
            name: "God Banana",
            emoji: "🌟",
            rarity: .mythic,
            unlockMethod: .prestige(25),
            description: "The ultimate banana",
            particleEffect: "divine_aura",
            animationType: .rainbow
        ),
        BananaSkin(
            id: "infinity_banana",
            name: "Infinity Banana",
            emoji: "♾️",
            rarity: .mythic,
            unlockMethod: .achievement("prestige_50"),
            description: "Unlimited power",
            particleEffect: "infinity_particles",
            animationType: .sparkle
        ),

        // Seasonal
        BananaSkin(
            id: "halloween_banana",
            name: "Spooky Banana",
            emoji: "🎃",
            rarity: .epic,
            unlockMethod: .seasonal("halloween"),
            description: "Boo! Limited edition",
            particleEffect: "bats",
            animationType: .bounce
        ),
        BananaSkin(
            id: "christmas_banana",
            name: "Santa Banana",
            emoji: "🎅",
            rarity: .epic,
            unlockMethod: .seasonal("christmas"),
            description: "Ho ho ho! Limited edition",
            particleEffect: "snowflakes",
            animationType: .bounce
        ),
        BananaSkin(
            id: "valentine_banana",
            name: "Love Banana",
            emoji: "💝",
            rarity: .rare,
            unlockMethod: .seasonal("valentine"),
            description: "Spread the love",
            particleEffect: "hearts",
            animationType: .pulse
        ),

        // Premium
        BananaSkin(
            id: "premium_gold",
            name: "24K Gold Banana",
            emoji: "🥇",
            rarity: .legendary,
            unlockMethod: .premium,
            description: "Pure gold perfection",
            particleEffect: "gold_sparkles",
            animationType: .sparkle
        ),
        BananaSkin(
            id: "premium_platinum",
            name: "Platinum Banana",
            emoji: "⭐️",
            rarity: .mythic,
            unlockMethod: .premium,
            description: "The rarest of them all",
            particleEffect: "platinum_aura",
            animationType: .rainbow
        )
    ]

    static func getSkin(byId id: String) -> BananaSkin? {
        allSkins.first { $0.id == id }
    }
}
