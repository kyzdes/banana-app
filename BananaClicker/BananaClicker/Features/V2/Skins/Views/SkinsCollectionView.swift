//
//  SkinsCollectionView.swift
//  BananaClicker V2.0
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI

struct SkinsCollectionView: View {
    @Binding var skinCollection: SkinCollection
    @Binding var currentClicks: Int

    @State private var selectedRarity: BananaSkin.Rarity? = nil

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Stats header
                headerView

                // Rarity filter
                rarityFilterView

                // Skins grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredSkins) { skin in
                            SkinCard(
                                skin: skin,
                                isOwned: skinCollection.owns(skin.id),
                                isEquipped: skinCollection.equippedSkinId == skin.id,
                                onEquip: {
                                    skinCollection.equipSkin(skin.id)
                                    HapticManager.shared.playSuccessHaptic()
                                },
                                onPurchase: {
                                    purchaseSkin(skin)
                                },
                                currentClicks: currentClicks
                            )
                        }
                    }
                    .padding()
                }
            }
            .background(Color.appBackground)
            .navigationTitle("🎨 Skins")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Collection")
                        .font(.headlineMedium)
                        .foregroundStyle(.primaryText)

                    Text("\(skinCollection.ownedSkinIds.count) / \(BananaSkin.allSkins.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.bananaPrimary)
                }

                Spacer()

                // Currently equipped
                VStack {
                    if let equipped = BananaSkin.getSkin(byId: skinCollection.equippedSkinId) {
                        Text(equipped.emoji)
                            .font(.system(size: 50))

                        Text("Equipped")
                            .font(.labelSmall)
                            .foregroundStyle(.secondaryText)
                    }
                }
            }

            // Progress bar
            ProgressView(value: Double(skinCollection.ownedSkinIds.count), total: Double(BananaSkin.allSkins.count))
                .tint(.bananaPrimary)
        }
        .padding()
        .background(Color.secondaryBackground)
    }

    private var rarityFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: selectedRarity == nil,
                    color: .gray
                ) {
                    selectedRarity = nil
                }

                ForEach(BananaSkin.Rarity.allCases, id: \.self) { rarity in
                    FilterChip(
                        title: rarity.rawValue,
                        isSelected: selectedRarity == rarity,
                        color: rarity.color
                    ) {
                        selectedRarity = rarity
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    private var filteredSkins: [BananaSkin] {
        if let rarity = selectedRarity {
            return BananaSkin.allSkins.filter { $0.rarity == rarity }
        }
        return BananaSkin.allSkins
    }

    private func purchaseSkin(_ skin: BananaSkin) {
        guard case .purchase(let cost) = skin.unlockMethod,
              currentClicks >= cost else { return }

        currentClicks -= cost
        skinCollection.unlockSkin(skin.id)
        skinCollection.equipSkin(skin.id)

        HapticManager.shared.playSuccessHaptic()
        SoundManager.shared.playSuccessSound()
    }
}

struct SkinCard: View {
    let skin: BananaSkin
    let isOwned: Bool
    let isEquipped: Bool
    let onEquip: () -> Void
    let onPurchase: () -> Void
    let currentClicks: Int

    var body: some View {
        VStack(spacing: 12) {
            // Emoji
            ZStack {
                Circle()
                    .fill(skin.rarity.color.opacity(0.2))
                    .frame(width: 80, height: 80)

                if isOwned {
                    Text(skin.emoji)
                        .font(.system(size: 50))
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title)
                        .foregroundStyle(Color.gray)
                }

                if isEquipped {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.accentGreen)
                                .background(Circle().fill(Color.white).padding(2))
                        }
                    }
                }
            }

            // Name
            Text(skin.name)
                .font(.labelMedium)
                .foregroundStyle(.primaryText)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            // Rarity badge
            Text(skin.rarity.rawValue)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Capsule().fill(skin.rarity.color.opacity(0.2)))
                .foregroundStyle(skin.rarity.color)

            // Action button
            if isOwned {
                if !isEquipped {
                    Button("Equip") {
                        onEquip()
                    }
                    .font(.labelMedium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.bananaPrimary))
                    .foregroundStyle(.white)
                } else {
                    Text("Equipped")
                        .font(.labelSmall)
                        .foregroundStyle(.secondaryText)
                }
            } else {
                unlockButton
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(skin.rarity.color.opacity(0.5), lineWidth: 2)
                )
        )
    }

    @ViewBuilder
    private var unlockButton: some View {
        switch skin.unlockMethod {
        case .purchase(let cost):
            Button {
                onPurchase()
            } label: {
                Text("\(formatNumber(cost))")
                    .font(.labelSmall)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(currentClicks >= cost ? Color.bananaPrimary : Color.gray.opacity(0.5))
                    )
                    .foregroundStyle(.white)
            }
            .disabled(currentClicks < cost)

        case .achievement(let id):
            Text("🏆 \(id)")
                .font(.caption2)
                .foregroundStyle(.secondaryText)

        case .prestige(let level):
            Text("✨ P\(level)")
                .font(.caption2)
                .foregroundStyle(.secondaryText)

        case .seasonal(let event):
            Text("🎃 \(event)")
                .font(.caption2)
                .foregroundStyle(.secondaryText)

        case .premium:
            Text("💎 Premium")
                .font(.caption2)
                .foregroundStyle(.secondaryText)

        case .starter, .quest:
            Text("Locked")
                .font(.caption2)
                .foregroundStyle(.secondaryText)
        }
    }

    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000)
        } else {
            return "\(number)"
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.bodySmall)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? color : Color.secondaryBackground)
                )
                .foregroundStyle(isSelected ? .white : .primaryText)
        }
    }
}

#Preview {
    @Previewable @State var collection = SkinCollection()
    @Previewable @State var clicks = 100000

    SkinsCollectionView(skinCollection: $collection, currentClicks: $clicks)
}
