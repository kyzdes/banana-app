//
//  Upgrade.swift
//  BananaClicker V2.0
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import SwiftData

/// Player's upgrade progression
@Model
final class PlayerUpgrades {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var ownedUpgrades: [String: Int] // upgrade ID -> level
    var activeAutoClickers: Int
    var totalClickMultiplier: Double
    var passiveClicksPerSecond: Double

    init(userId: UUID) {
        self.id = UUID()
        self.userId = userId
        self.ownedUpgrades = [:]
        self.activeAutoClickers = 0
        self.totalClickMultiplier = 1.0
        self.passiveClicksPerSecond = 0.0
    }

    /// Get level of specific upgrade
    func getUpgradeLevel(_ upgradeId: String) -> Int {
        ownedUpgrades[upgradeId] ?? 0
    }

    /// Purchase upgrade
    func purchaseUpgrade(_ upgrade: Upgrade, currentClicks: Int) -> Bool {
        let currentLevel = getUpgradeLevel(upgrade.id)
        let cost = upgrade.costForLevel(currentLevel + 1)

        guard currentClicks >= cost else { return false }

        ownedUpgrades[upgrade.id] = currentLevel + 1
        recalculateStats()
        return true
    }

    /// Recalculate total multipliers and passive income
    private func recalculateStats() {
        var multiplier = 1.0
        var passiveCPS = 0.0

        for (upgradeId, level) in ownedUpgrades {
            if let upgrade = Upgrade.allUpgrades.first(where: { $0.id == upgradeId }) {
                switch upgrade.type {
                case .clickMultiplier(let mult):
                    multiplier += mult * Double(level)
                case .autoClicker(let cps):
                    passiveCPS += cps * Double(level)
                    activeAutoClickers = level
                case .passiveIncome(let cps):
                    passiveCPS += cps * Double(level)
                }
            }
        }

        totalClickMultiplier = multiplier
        passiveClicksPerSecond = passiveCPS
    }
}

/// Upgrade definition
struct Upgrade: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let baseCost: Int
    let maxLevel: Int
    let type: UpgradeType
    let rarity: Rarity

    enum UpgradeType: Codable {
        case clickMultiplier(Double)
        case autoClicker(Double) // CPS
        case passiveIncome(Double) // CPS
    }

    enum Rarity: String, Codable {
        case common
        case rare
        case epic
        case legendary
    }

    /// Calculate cost for specific level
    func costForLevel(_ level: Int) -> Int {
        return Int(Double(baseCost) * pow(1.15, Double(level - 1)))
    }
}

// MARK: - Upgrades Catalog
extension Upgrade {
    static let allUpgrades: [Upgrade] = [
        // Auto-Clickers
        Upgrade(
            id: "basic_auto",
            name: "Basic Auto-Clicker",
            description: "Generates 1 click per second",
            icon: "hand.tap",
            baseCost: 100,
            maxLevel: 100,
            type: .autoClicker(1.0),
            rarity: .common
        ),
        Upgrade(
            id: "fast_auto",
            name: "Fast Auto-Clicker",
            description: "Generates 10 clicks per second",
            icon: "bolt.fill",
            baseCost: 1_000,
            maxLevel: 100,
            type: .autoClicker(10.0),
            rarity: .rare
        ),
        Upgrade(
            id: "mega_auto",
            name: "Mega Auto-Clicker",
            description: "Generates 100 clicks per second",
            icon: "bolt.circle.fill",
            baseCost: 50_000,
            maxLevel: 50,
            type: .autoClicker(100.0),
            rarity: .epic
        ),

        // Click Multipliers
        Upgrade(
            id: "double_tap",
            name: "Double Tap",
            description: "+100% click power",
            icon: "hand.tap.fill",
            baseCost: 500,
            maxLevel: 25,
            type: .clickMultiplier(1.0),
            rarity: .common
        ),
        Upgrade(
            id: "power_click",
            name: "Power Click",
            description: "+500% click power",
            icon: "flame.fill",
            baseCost: 10_000,
            maxLevel: 20,
            type: .clickMultiplier(5.0),
            rarity: .rare
        ),
        Upgrade(
            id: "god_finger",
            name: "God Finger",
            description: "+2000% click power",
            icon: "sparkles",
            baseCost: 1_000_000,
            maxLevel: 10,
            type: .clickMultiplier(20.0),
            rarity: .legendary
        ),

        // Passive Income
        Upgrade(
            id: "banana_farm",
            name: "Banana Farm",
            description: "Grows 5 bananas per second",
            icon: "leaf.fill",
            baseCost: 2_000,
            maxLevel: 100,
            type: .passiveIncome(5.0),
            rarity: .common
        ),
        Upgrade(
            id: "banana_factory",
            name: "Banana Factory",
            description: "Produces 50 bananas per second",
            icon: "building.2.fill",
            baseCost: 100_000,
            maxLevel: 50,
            type: .passiveIncome(50.0),
            rarity: .epic
        ),
        Upgrade(
            id: "banana_empire",
            name: "Banana Empire",
            description: "Generates 500 bananas per second",
            icon: "crown.fill",
            baseCost: 10_000_000,
            maxLevel: 25,
            type: .passiveIncome(500.0),
            rarity: .legendary
        )
    ]
}
