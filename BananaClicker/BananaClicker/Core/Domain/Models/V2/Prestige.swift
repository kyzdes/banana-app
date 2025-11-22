//
//  Prestige.swift
//  BananaClicker V2.0
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import SwiftData

/// Prestige system for advanced progression
@Model
final class PrestigeData {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var prestigeLevel: Int
    var totalPrestiges: Int
    var goldenBananas: Int
    var prestigeMultiplier: Double
    var lastPrestigeDate: Date?
    var prestigePerks: [String: Int] // perk ID -> level

    init(userId: UUID) {
        self.id = UUID()
        self.userId = userId
        self.prestigeLevel = 0
        self.totalPrestiges = 0
        self.goldenBananas = 0
        self.prestigeMultiplier = 1.0
        self.lastPrestigeDate = nil
        self.prestigePerks = [:]
    }

    /// Calculate clicks required for next prestige
    func clicksForNextPrestige() -> Int {
        let baseRequirement = 1_000_000
        return baseRequirement * Int(pow(10.0, Double(prestigeLevel)))
    }

    /// Perform prestige
    func performPrestige() {
        prestigeLevel += 1
        totalPrestiges += 1
        lastPrestigeDate = Date()

        // Award golden bananas based on prestige level
        let reward = prestigeLevel * 10
        goldenBananas += reward

        // Increase multiplier
        prestigeMultiplier += 0.1 * Double(prestigeLevel)
    }
}

/// Prestige perk definition
struct PrestigePerk: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let maxLevel: Int
    let costPerLevel: Int // in golden bananas
    let icon: String
    let effect: PerkEffect

    enum PerkEffect: Codable {
        case clickMultiplier(Double)
        case autoClickerBoost(Double)
        case offlineEarnings(Double)
        case questRewards(Double)
        case pvpBonus(Double)
    }
}

// MARK: - Prestige Perks Catalog
extension PrestigePerk {
    static let allPerks: [PrestigePerk] = [
        PrestigePerk(
            id: "golden_touch",
            name: "Golden Touch",
            description: "+10% click power per level",
            maxLevel: 10,
            costPerLevel: 5,
            icon: "hand.tap.fill",
            effect: .clickMultiplier(0.1)
        ),
        PrestigePerk(
            id: "automation",
            name: "Automation Master",
            description: "+20% auto-clicker efficiency",
            maxLevel: 10,
            costPerLevel: 10,
            icon: "gearshape.2.fill",
            effect: .autoClickerBoost(0.2)
        ),
        PrestigePerk(
            id: "passive_income",
            name: "Passive Income",
            description: "+50% offline earnings",
            maxLevel: 5,
            costPerLevel: 15,
            icon: "moon.stars.fill",
            effect: .offlineEarnings(0.5)
        ),
        PrestigePerk(
            id: "quest_master",
            name: "Quest Master",
            description: "+25% quest rewards",
            maxLevel: 10,
            costPerLevel: 8,
            icon: "star.fill",
            effect: .questRewards(0.25)
        ),
        PrestigePerk(
            id: "battle_ready",
            name: "Battle Ready",
            description: "+15% PvP performance",
            maxLevel: 10,
            costPerLevel: 12,
            icon: "bolt.fill",
            effect: .pvpBonus(0.15)
        )
    ]
}
