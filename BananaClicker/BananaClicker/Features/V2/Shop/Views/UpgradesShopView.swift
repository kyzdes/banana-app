//
//  UpgradesShopView.swift
//  BananaClicker V2.0
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI

struct UpgradesShopView: View {
    @Binding var playerUpgrades: PlayerUpgrades
    @Binding var currentClicks: Int

    @State private var selectedCategory: UpgradeCategory = .all

    enum UpgradeCategory: String, CaseIterable {
        case all = "All"
        case autoClickers = "Auto"
        case multipliers = "Mult"
        case passive = "Passive"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Stats header
                statsHeaderView

                // Category selector
                Picker("Category", selection: $selectedCategory) {
                    ForEach(UpgradeCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // Upgrades list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredUpgrades) { upgrade in
                            UpgradeRow(
                                upgrade: upgrade,
                                currentLevel: playerUpgrades.getUpgradeLevel(upgrade.id),
                                currentClicks: currentClicks,
                                onPurchase: {
                                    purchaseUpgrade(upgrade)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .background(Color.appBackground)
            .navigationTitle("🛒 Shop")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var statsHeaderView: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Click Power",
                value: String(format: "%.1fx", playerUpgrades.totalClickMultiplier),
                icon: "hand.tap.fill"
            )

            StatCard(
                title: "Passive CPS",
                value: String(format: "%.1f", playerUpgrades.passiveClicksPerSecond),
                icon: "gearshape.2.fill"
            )

            StatCard(
                title: "Auto-Clickers",
                value: "\(playerUpgrades.activeAutoClickers)",
                icon: "bolt.circle.fill"
            )
        }
        .padding()
        .background(Color.secondaryBackground)
    }

    private var filteredUpgrades: [Upgrade] {
        Upgrade.allUpgrades.filter { upgrade in
            switch selectedCategory {
            case .all:
                return true
            case .autoClickers:
                if case .autoClicker = upgrade.type {
                    return true
                }
                return false
            case .multipliers:
                if case .clickMultiplier = upgrade.type {
                    return true
                }
                return false
            case .passive:
                if case .passiveIncome = upgrade.type {
                    return true
                }
                return false
            }
        }
    }

    private func purchaseUpgrade(_ upgrade: Upgrade) {
        let currentLevel = playerUpgrades.getUpgradeLevel(upgrade.id)
        let cost = upgrade.costForLevel(currentLevel + 1)

        guard currentClicks >= cost else { return }

        if playerUpgrades.purchaseUpgrade(upgrade, currentClicks: currentClicks) {
            currentClicks -= cost
            HapticManager.shared.playSuccessHaptic()
            SoundManager.shared.playSuccessSound()
        }
    }
}

struct UpgradeRow: View {
    let upgrade: Upgrade
    let currentLevel: Int
    let currentClicks: Int
    let onPurchase: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(rarityColor.opacity(0.2))
                    .frame(width: 60, height: 60)

                Image(systemName: upgrade.icon)
                    .font(.title2)
                    .foregroundStyle(rarityColor)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(upgrade.name)
                        .font(.headlineMedium)
                        .foregroundStyle(.primaryText)

                    if currentLevel > 0 {
                        Text("Lv. \(currentLevel)")
                            .font(.labelSmall)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(rarityColor.opacity(0.2)))
                            .foregroundStyle(rarityColor)
                    }
                }

                Text(upgrade.description)
                    .font(.bodySmall)
                    .foregroundStyle(.secondaryText)

                // Effect display
                effectText
                    .font(.labelMedium)
                    .foregroundStyle(.bananaPrimary)
            }

            Spacer()

            // Purchase button
            VStack(spacing: 4) {
                if currentLevel < upgrade.maxLevel {
                    let cost = upgrade.costForLevel(currentLevel + 1)
                    let canAfford = currentClicks >= cost

                    Button {
                        onPurchase()
                    } label: {
                        VStack(spacing: 4) {
                            Text(formatCost(cost))
                                .font(.labelLarge)
                                .fontWeight(.bold)

                            Image(systemName: "arrow.up.circle.fill")
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(canAfford ? rarityColor : Color.gray.opacity(0.5))
                        )
                        .foregroundStyle(.white)
                    }
                    .disabled(!canAfford)
                } else {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.accentGreen)
                            .font(.title2)

                        Text("MAX")
                            .font(.labelSmall)
                            .foregroundStyle(.secondaryText)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(rarityColor.opacity(0.3), lineWidth: 2)
                )
        )
    }

    private var rarityColor: Color {
        switch upgrade.rarity {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }

    private var effectText: Text {
        switch upgrade.type {
        case .clickMultiplier(let mult):
            return Text("+\(Int(mult * 100))% click power")
        case .autoClicker(let cps):
            return Text("+\(Int(cps)) CPS")
        case .passiveIncome(let cps):
            return Text("+\(Int(cps)) passive CPS")
        }
    }

    private func formatCost(_ cost: Int) -> String {
        if cost >= 1_000_000_000 {
            return String(format: "%.1fB", Double(cost) / 1_000_000_000)
        } else if cost >= 1_000_000 {
            return String(format: "%.1fM", Double(cost) / 1_000_000)
        } else if cost >= 1_000 {
            return String(format: "%.1fK", Double(cost) / 1_000)
        } else {
            return "\(cost)"
        }
    }
}

#Preview {
    @Previewable @State var upgrades = PlayerUpgrades(userId: UUID())
    @Previewable @State var clicks = 10000

    UpgradesShopView(playerUpgrades: $upgrades, currentClicks: $clicks)
}
