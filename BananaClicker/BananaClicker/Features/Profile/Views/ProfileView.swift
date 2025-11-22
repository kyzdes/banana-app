//
//  ProfileView.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI
import Charts

/// User profile and settings view
struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                if viewModel.isLoading && viewModel.user == nil {
                    LoadingView()
                } else if let error = viewModel.error, viewModel.user == nil {
                    ErrorView(error: error) {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                } else {
                    contentView
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(viewModel: $viewModel)
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - View Components

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile header
                profileHeaderView

                // Stats overview
                statsOverviewView

                // Achievements section
                achievementsView

                // Activity chart
                if let stats = viewModel.clickStats {
                    activityChartView(stats: stats)
                }

                Spacer(minLength: 50)
            }
            .padding()
        }
    }

    private var profileHeaderView: some View {
        VStack(spacing: 16) {
            if let user = viewModel.user {
                // Avatar
                Text(user.avatarEmoji)
                    .font(.system(size: 80))
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.bananaPrimary.opacity(0.2))
                    )

                // Nickname and rank
                VStack(spacing: 8) {
                    Text(user.nickname)
                        .font(.displayMedium)
                        .foregroundStyle(.primaryText)

                    HStack(spacing: 16) {
                        Label("Rank #\(user.rank)", systemImage: "trophy.fill")
                            .font(.bodyLarge)
                            .foregroundStyle(.bananaPrimary)

                        Text("•")
                            .foregroundStyle(.tertiaryText)

                        Label("\(user.friendsCount) friends", systemImage: "person.2.fill")
                            .font(.bodyLarge)
                            .foregroundStyle(.secondaryText)
                    }
                }

                // Join info
                VStack(spacing: 4) {
                    Text("Joined \(viewModel.formattedJoinDate)")
                        .font(.bodySmall)
                        .foregroundStyle(.secondaryText)

                    Text("Last active \(viewModel.formattedLastActive)")
                        .font(.bodySmall)
                        .foregroundStyle(.tertiaryText)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondaryBackground)
        )
    }

    private var statsOverviewView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headlineLarge)
                .foregroundStyle(.primaryText)

            if let stats = viewModel.clickStats {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        StatCard(
                            title: "Total Clicks",
                            value: formatNumber(stats.totalClicks),
                            icon: "hand.tap.fill"
                        )

                        StatCard(
                            title: "This Week",
                            value: formatNumber(stats.clicksThisWeek),
                            icon: "calendar"
                        )
                    }

                    HStack(spacing: 12) {
                        StatCard(
                            title: "Avg CPS",
                            value: String(format: "%.1f", stats.averageCPS),
                            icon: "speedometer"
                        )

                        StatCard(
                            title: "Play Time",
                            value: viewModel.formattedTotalPlayTime,
                            icon: "clock.fill"
                        )
                    }
                }
            }
        }
    }

    private var achievementsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.headlineLarge)
                .foregroundStyle(.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    AchievementBadge(title: "Novice", emoji: "🌱", achieved: true)
                    AchievementBadge(title: "Enthusiast", emoji: "⚡️", achieved: true)
                    AchievementBadge(title: "Master", emoji: "🏆", achieved: false)
                    AchievementBadge(title: "Legend", emoji: "👑", achieved: false)
                }
            }
        }
    }

    private func activityChartView(stats: ClickStats) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity (Last 7 Days)")
                .font(.headlineLarge)
                .foregroundStyle(.primaryText)

            Chart(stats.dailyHistory) { day in
                BarMark(
                    x: .value("Date", day.date, unit: .day),
                    y: .value("Clicks", day.clickCount)
                )
                .foregroundStyle(Color.bananaPrimary)
            }
            .frame(height: 200)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.secondaryBackground)
            )
        }
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0

        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000)
        } else {
            return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
        }
    }
}

// MARK: - Achievement Badge

struct AchievementBadge: View {
    let title: String
    let emoji: String
    let achieved: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 40))
                .opacity(achieved ? 1.0 : 0.3)

            Text(title)
                .font(.labelSmall)
                .foregroundStyle(achieved ? .primaryText : .tertiaryText)
        }
        .frame(width: 100, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(achieved ? Color.bananaPrimary.opacity(0.2) : Color.secondaryBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(achieved ? Color.bananaPrimary : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}
