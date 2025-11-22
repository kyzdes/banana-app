//
//  MainTabView.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI
import SwiftData

/// Main tab view containing all app screens
struct MainTabView: View {
    @State private var selectedTab: Tab = .game

    enum Tab {
        case game
        case leaderboard
        case friends
        case profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            GameView()
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
        }
        .tint(.bananaPrimary)
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .modelContainer(for: ClickSession.self, inMemory: true)
}
