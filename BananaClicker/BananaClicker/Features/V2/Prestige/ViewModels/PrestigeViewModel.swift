//
//  PrestigeViewModel.swift
//  BananaClicker V2.0
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class PrestigeViewModel {
    var prestigeData: PrestigeData?
    var canPrestige: Bool = false
    var showConfirmation: Bool = false

    func checkPrestigeEligibility(currentClicks: Int) {
        guard let data = prestigeData else { return }
        canPrestige = currentClicks >= data.clicksForNextPrestige()
    }

    func performPrestige() -> (goldenBananas: Int, multiplier: Double) {
        guard let data = prestigeData else {
            return (0, 1.0)
        }

        data.performPrestige()
        return (data.goldenBananas, data.prestigeMultiplier)
    }

    func getCost(for perkId: String) -> Int {
        guard let data = prestigeData,
              let perk = PrestigePerk.allPerks.first(where: { $0.id == perkId }) else {
            return 0
        }

        let currentLevel = data.prestigePerks[perkId] ?? 0
        return perk.costPerLevel * (currentLevel + 1)
    }

    func canAffordPerk(_ perkId: String) -> Bool {
        guard let data = prestigeData else { return false }
        return data.goldenBananas >= getCost(for: perkId)
    }

    func purchasePerk(_ perkId: String) -> Bool {
        guard let data = prestigeData,
              canAffordPerk(perkId),
              let perk = PrestigePerk.allPerks.first(where: { $0.id == perkId }) else {
            return false
        }

        let currentLevel = data.prestigePerks[perkId] ?? 0
        guard currentLevel < perk.maxLevel else { return false }

        let cost = getCost(for: perkId)
        data.goldenBananas -= cost
        data.prestigePerks[perkId] = currentLevel + 1

        return true
    }
}
