//
//  LeaderboardView.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI

/// Leaderboard view showing player rankings
struct LeaderboardView: View {
    @State private var viewModel = LeaderboardViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                if viewModel.isLoading && !viewModel.hasData {
                    LoadingView()
                } else if let error = viewModel.error, viewModel.isEmpty {
                    ErrorView(error: error) {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                } else if viewModel.isEmpty {
                    EmptyStateView(
                        icon: "chart.bar.fill",
                        title: "No Rankings Yet",
                        message: "Start clicking to appear on the leaderboard!",
                        actionTitle: "Refresh",
                        action: {
                            Task {
                                await viewModel.refresh()
                            }
                        }
                    )
                } else {
                    contentView
                }
            }
            .navigationTitle("🏆 Leaderboard")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - View Components

    private var contentView: some View {
        VStack(spacing: 0) {
            // Type selector
            typeSelectorView
                .padding(.horizontal)
                .padding(.top)

            // Leaderboard list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.entries) { entry in
                        NavigationLink {
                            userDetailView(entry: entry)
                        } label: {
                            LeaderboardRowView(entry: entry)
                        }
                        .buttonStyle(.plain)
                    }

                    // Current user entry (if not in top list)
                    if let currentUser = viewModel.currentUserEntry,
                       !viewModel.entries.contains(where: { $0.isCurrentUser }) {
                        Divider()
                            .padding(.vertical, 8)

                        LeaderboardRowView(entry: currentUser)
                    }
                }
                .padding()
            }

            // Total players footer
            footerView
        }
    }

    private var typeSelectorView: some View {
        Picker("Leaderboard Type", selection: $viewModel.selectedType) {
            ForEach(LeaderboardType.allCases, id: \.self) { type in
                Label(type.rawValue, systemImage: type.icon)
                    .tag(type)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.selectedType) { oldValue, newValue in
            Task {
                await viewModel.changeType(newValue)
            }
        }
    }

    private var footerView: some View {
        HStack {
            Image(systemName: "person.3.fill")
                .foregroundStyle(.secondaryText)

            Text("\(viewModel.totalPlayers) total players")
                .font(.bodySmall)
                .foregroundStyle(.secondaryText)

            Spacer()

            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding()
        .background(Color.secondaryBackground)
    }

    private func userDetailView(entry: LeaderboardEntry) -> some View {
        VStack(spacing: 20) {
            Text(entry.avatarEmoji)
                .font(.system(size: 100))

            Text(entry.nickname)
                .font(.displayMedium)
                .foregroundStyle(.primaryText)

            if let medal = entry.medalEmoji {
                Text(medal)
                    .font(.system(size: 60))
            }

            VStack(spacing: 8) {
                Text("Rank #\(entry.rank)")
                    .font(.headlineLarge)
                    .foregroundStyle(.bananaPrimary)

                Text(entry.formattedClicks + " total clicks")
                    .font(.bodyLarge)
                    .foregroundStyle(.secondaryText)
            }

            if entry.isFriend {
                Label("Friend", systemImage: "checkmark.circle.fill")
                    .font(.bodyMedium)
                    .foregroundStyle(.accentGreen)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Player Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview {
    LeaderboardView()
}
