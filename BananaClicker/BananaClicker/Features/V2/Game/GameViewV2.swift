//
//  GameViewV2.swift
//  BananaClicker V2.0
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI
import SwiftData

/// Enhanced Game View with V2.0 features
struct GameViewV2: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = GameViewModel()

    // V2.0 State
    @State private var playerUpgrades = PlayerUpgrades(userId: UUID())
    @State private var skinCollection = SkinCollection()
    @State private var questProgress = QuestProgress(userId: UUID())
    @State private var rewardProgress = DailyRewardProgress(userId: UUID())
    @State private var prestigeData = PrestigeData(userId: UUID())

    // UI State
    @State private var showShop = false
    @State private var showSkins = false
    @State private var showQuests = false
    @State private var showRewards = false
    @State private var showPrestige = false

    private let userId = UUID()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    LoadingView()
                } else {
                    mainGameView
                }
            }
            .navigationTitle("Banana Clicker V2.0")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    resourcesDisplay
                }

                ToolbarItem(placement: .topBarTrailing) {
                    quickActionsMenu
                }
            }
            .sheet(isPresented: $showShop) {
                UpgradesShopView(playerUpgrades: $playerUpgrades, currentClicks: $viewModel.totalClicks)
            }
            .sheet(isPresented: $showSkins) {
                SkinsCollectionView(skinCollection: $skinCollection, currentClicks: $viewModel.totalClicks)
            }
            .sheet(isPresented: $showQuests) {
                DailyQuestsView(questProgress: $questProgress)
            }
            .sheet(isPresented: $showRewards) {
                DailyRewardsView(rewardProgress: $rewardProgress, onClaim: { reward in
                    viewModel.totalClicks += reward.clicks
                })
            }
            .sheet(isPresented: $showPrestige) {
                PrestigeView(currentClicks: viewModel.totalClicks) {
                    // Reset clicks, apply prestige
                    viewModel.totalClicks = 0
                    viewModel.sessionClicks = 0
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    private var mainGameView: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Quick stats cards
                quickStatsView

                // Click counter
                clickCounterView

                // Banana button (with equipped skin)
                bananaButtonView

                // Features grid
                featuresGridView

                // Active upgrades display
                activeUpgradesView

                Spacer(minLength: 50)
            }
            .padding()
        }
    }

    private var resourcesDisplay: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(formatNumber(viewModel.totalClicks))
                .font(.headlineMedium)
                .foregroundStyle(.bananaPrimary)

            Text("#\(viewModel.rank)")
                .font(.caption)
                .foregroundStyle(.secondaryText)
        }
    }

    private var quickActionsMenu: some View {
        Menu {
            Button {
                showShop = true
            } label: {
                Label("Shop", systemImage: "cart.fill")
            }

            Button {
                showSkins = true
            } label: {
                Label("Skins", systemImage: "paintbrush.fill")
            }

            Button {
                showQuests = true
            } label: {
                Label("Quests", systemImage: "checkmark.circle.fill")
            }

            Button {
                showRewards = true
            } label: {
                Label("Daily Rewards", systemImage: "gift.fill")
            }

            Button {
                showPrestige = true
            } label: {
                Label("Prestige", systemImage: "sparkles")
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.title2)
                .foregroundStyle(.bananaPrimary)
        }
    }

    private var quickStatsView: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "CPS",
                value: String(format: "%.1f", viewModel.clicksPerSecond + playerUpgrades.passiveClicksPerSecond),
                icon: "speedometer"
            )

            StatCard(
                title: "Multiplier",
                value: String(format: "%.1fx", playerUpgrades.totalClickMultiplier),
                icon: "bolt.fill"
            )

            StatCard(
                title: "Prestige",
                value: "\(prestigeData.prestigeLevel)",
                icon: "star.fill"
            )
        }
    }

    private var clickCounterView: some View {
        VStack(spacing: 8) {
            Text(viewModel.formattedClicks)
                .font(.clickCounter)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.bananaPrimary, Color(hex: "#FFA500")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .contentTransition(.numericText())

            Text("🍌 total bananas")
                .font(.headlineMedium)
                .foregroundStyle(.secondaryText)

            if viewModel.showPlusOne {
                Text("+\(Int(playerUpgrades.totalClickMultiplier))")
                    .font(.title)
                    .foregroundStyle(.accentGreen)
                    .offset(y: viewModel.plusOneOffset)
                    .opacity(viewModel.showPlusOne ? 1 : 0)
                    .transition(.opacity)
            }
        }
        .padding()
    }

    private var bananaButtonView: some View {
        let equippedSkin = BananaSkin.getSkin(byId: skinCollection.equippedSkinId)

        return Button(action: {
            Task {
                let clickPower = Int(playerUpgrades.totalClickMultiplier * prestigeData.prestigeMultiplier)
                viewModel.totalClicks += clickPower

                await viewModel.handleClick(userId: userId, modelContext: modelContext)

                // Update quest progress
                if let clickQuestIndex = questProgress.dailyQuests.firstIndex(where: { $0.quest.type == .clicks }) {
                    questProgress.updateProgress(
                        questId: questProgress.dailyQuests[clickQuestIndex].quest.id,
                        progress: questProgress.dailyQuests[clickQuestIndex].progress + clickPower
                    )
                }
            }
        }) {
            Text(equippedSkin?.emoji ?? "🍌")
                .font(.system(size: 150))
                .scaleEffect(viewModel.bananaScale)
                .rotationEffect(.degrees(viewModel.bananaRotation))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .idlePulse()
        .padding(.vertical, 20)
    }

    private var featuresGridView: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        return LazyVGrid(columns: columns, spacing: 12) {
            FeatureCard(
                title: "Shop",
                icon: "cart.fill",
                color: .blue,
                badge: "\(Upgrade.allUpgrades.count)"
            ) {
                showShop = true
            }

            FeatureCard(
                title: "Skins",
                icon: "paintbrush.fill",
                color: .purple,
                badge: "\(skinCollection.ownedSkinIds.count)/\(BananaSkin.allSkins.count)"
            ) {
                showSkins = true
            }

            FeatureCard(
                title: "Quests",
                icon: "checkmark.circle.fill",
                color: .green,
                badge: "\(questProgress.dailyQuests.filter { $0.isCompleted }.count)/3"
            ) {
                showQuests = true
            }

            FeatureCard(
                title: "Rewards",
                icon: "gift.fill",
                color: .orange,
                badge: rewardProgress.canClaimToday() ? "!" : "✓"
            ) {
                showRewards = true
            }
        }
    }

    private var activeUpgradesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Bonuses")
                .font(.headlineMedium)
                .foregroundStyle(.primaryText)

            VStack(spacing: 8) {
                if playerUpgrades.activeAutoClickers > 0 {
                    BonusRow(
                        icon: "gearshape.2.fill",
                        title: "Auto-Clickers",
                        value: "\(playerUpgrades.activeAutoClickers) active"
                    )
                }

                if playerUpgrades.totalClickMultiplier > 1 {
                    BonusRow(
                        icon: "hand.tap.fill",
                        title: "Click Power",
                        value: String(format: "%.1fx", playerUpgrades.totalClickMultiplier)
                    )
                }

                if playerUpgrades.passiveClicksPerSecond > 0 {
                    BonusRow(
                        icon: "leaf.fill",
                        title: "Passive Income",
                        value: String(format: "%.1f/sec", playerUpgrades.passiveClicksPerSecond)
                    )
                }

                if prestigeData.prestigeLevel > 0 {
                    BonusRow(
                        icon: "sparkles",
                        title: "Prestige Bonus",
                        value: String(format: "%.1fx", prestigeData.prestigeMultiplier)
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondaryBackground)
        )
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

struct FeatureCard: View {
    let title: String
    let icon: String
    let color: Color
    let badge: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundStyle(color)

                    Text(badge)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(color))
                        .foregroundStyle(.white)
                }

                Text(title)
                    .font(.bodyMedium)
                    .foregroundStyle(.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(color.opacity(0.3), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct BonusRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.bananaPrimary)
                .frame(width: 30)

            Text(title)
                .font(.bodySmall)
                .foregroundStyle(.primaryText)

            Spacer()

            Text(value)
                .font(.bodySmall)
                .fontWeight(.semibold)
                .foregroundStyle(.bananaPrimary)
        }
    }
}

#Preview {
    GameViewV2()
        .modelContainer(for: ClickSession.self, inMemory: true)
}
