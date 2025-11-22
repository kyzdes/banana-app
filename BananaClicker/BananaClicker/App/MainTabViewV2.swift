//
//  MainTabViewV2.swift
//  BananaClicker V2.0
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI
import SwiftData

/// Main tab view for V2.0 with enhanced navigation
struct MainTabViewV2: View {
    @State private var selectedTab: Tab = .game

    enum Tab {
        case game
        case leaderboard
        case friends
        case profile
        case more
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            GameViewV2()
                .tabItem {
                    Label("Game", systemImage: selectedTab == .game ? "hand.tap.fill" : "hand.tap")
                }
                .tag(Tab.game)

            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: selectedTab == .leaderboard ? "chart.bar.fill" : "chart.bar")
                }
                .tag(Tab.leaderboard)

            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: selectedTab == .friends ? "person.2.fill" : "person.2")
                }
                .tag(Tab.friends)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: selectedTab == .profile ? "person.circle.fill" : "person.circle")
                }
                .tag(Tab.profile)

            MoreView()
                .tabItem {
                    Label("More", systemImage: selectedTab == .more ? "ellipsis.circle.fill" : "ellipsis.circle")
                }
                .tag(Tab.more)
        }
        .tint(.bananaPrimary)
    }
}

/// More tab with additional features
struct MoreView: View {
    @State private var playerUpgrades = PlayerUpgrades(userId: UUID())
    @State private var skinCollection = SkinCollection()
    @State private var questProgress = QuestProgress(userId: UUID())
    @State private var rewardProgress = DailyRewardProgress(userId: UUID())
    @State private var clicks = 0

    var body: some View {
        NavigationStack {
            List {
                Section("Progression") {
                    NavigationLink {
                        UpgradesShopView(playerUpgrades: $playerUpgrades, currentClicks: $clicks)
                    } label: {
                        Label("Upgrades Shop", systemImage: "cart.fill")
                    }

                    NavigationLink {
                        PrestigeView(currentClicks: clicks) {}
                    } label: {
                        Label("Prestige System", systemImage: "sparkles")
                    }
                }

                Section("Customization") {
                    NavigationLink {
                        SkinsCollectionView(skinCollection: $skinCollection, currentClicks: $clicks)
                    } label: {
                        Label("Banana Skins", systemImage: "paintbrush.fill")
                    }
                }

                Section("Daily Content") {
                    NavigationLink {
                        DailyQuestsView(questProgress: $questProgress)
                    } label: {
                        Label("Daily Quests", systemImage: "checkmark.circle.fill")
                            .badge(questProgress.dailyQuests.filter { $0.isCompleted }.count)
                    }

                    NavigationLink {
                        DailyRewardsView(rewardProgress: $rewardProgress, onClaim: { _ in })
                    } label: {
                        Label("Login Rewards", systemImage: "gift.fill")
                            .badge(rewardProgress.canClaimToday() ? "!" : "")
                    }
                }

                Section("Coming Soon") {
                    Label("PvP Battles", systemImage: "shield.fill")
                        .foregroundStyle(.secondaryText)

                    Label("Guilds/Clans", systemImage: "person.3.fill")
                        .foregroundStyle(.secondaryText)

                    Label("Tournaments", systemImage: "trophy.fill")
                        .foregroundStyle(.secondaryText)

                    Label("Battle Pass", systemImage: "star.circle.fill")
                        .foregroundStyle(.secondaryText)

                    Label("Achievements", systemImage: "rosette")
                        .foregroundStyle(.secondaryText)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("2.0.0")
                            .foregroundStyle(.secondaryText)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("2025.11.22")
                            .foregroundStyle(.secondaryText)
                    }
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    MainTabViewV2()
        .modelContainer(for: ClickSession.self, inMemory: true)
}
