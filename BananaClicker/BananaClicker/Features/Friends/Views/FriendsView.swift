//
//  FriendsView.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI

/// Friends list view
struct FriendsView: View {
    @State private var viewModel = FriendsViewModel()

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
                    emptyStateView
                } else {
                    contentView
                }
            }
            .navigationTitle("👥 Friends")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showingAddFriend = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                    .disabled(!viewModel.canAddMoreFriends)
                }
            }
            .sheet(isPresented: $viewModel.showingAddFriend) {
                AddFriendView(viewModel: $viewModel)
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - View Components

    private var contentView: some View {
        VStack(spacing: 0) {
            // Header
            headerView
                .padding()
                .background(Color.secondaryBackground)

            // Friends list
            List {
                ForEach(viewModel.friends) { friend in
                    NavigationLink {
                        friendDetailView(friend: friend)
                    } label: {
                        FriendRowView(friend: friend)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let friend = viewModel.friends[index]
                        Task {
                            await viewModel.removeFriend(friend)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.friendsCount) Friends")
                    .font(.headlineLarge)
                    .foregroundStyle(.primaryText)

                Text("Max \(Constants.Friends.maxFriends)")
                    .font(.bodySmall)
                    .foregroundStyle(.secondaryText)
            }

            Spacer()

            Button {
                viewModel.showingAddFriend = true
            } label: {
                Label("Add Friend", systemImage: "person.badge.plus")
                    .font(.bodyMedium)
            }
            .buttonStyle(.bordered)
            .tint(.bananaPrimary)
            .disabled(!viewModel.canAddMoreFriends)
        }
    }

    private var emptyStateView: some View {
        EmptyStateView(
            icon: "person.2.slash",
            title: "No Friends Yet",
            message: "Add friends to compare scores and see how you rank!",
            actionTitle: "Add Friend",
            action: {
                viewModel.showingAddFriend = true
            }
        )
    }

    private func friendDetailView(friend: Friend) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Avatar
                Text(friend.avatarEmoji)
                    .font(.system(size: 100))

                // Name and rank
                VStack(spacing: 8) {
                    Text(friend.nickname)
                        .font(.displayMedium)
                        .foregroundStyle(.primaryText)

                    HStack(spacing: 16) {
                        Label("Rank #\(friend.rank)", systemImage: "trophy.fill")
                            .font(.bodyLarge)
                            .foregroundStyle(.bananaPrimary)
                    }
                }

                // Stats
                statsView(friend: friend)

                Spacer()

                // Actions
                VStack(spacing: 12) {
                    SecondaryButton("Compare Stats", icon: "chart.bar.xaxis") {
                        // TODO: Show comparison view
                    }

                    Button(role: .destructive) {
                        Task {
                            await viewModel.removeFriend(friend)
                        }
                    } label: {
                        Label("Remove Friend", systemImage: "person.badge.minus")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.bordered)
                    .tint(.accentRed)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Friend Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func statsView(friend: Friend) -> some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Total Clicks",
                value: formatNumber(friend.totalClicks),
                icon: "hand.tap.fill"
            )

            StatCard(
                title: "Rank",
                value: "#\(friend.rank)",
                icon: "trophy.fill"
            )
        }
        .padding(.horizontal)
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

/// Row view for a friend
struct FriendRowView: View {
    let friend: Friend

    var body: some View {
        HStack(spacing: 16) {
            Text(friend.avatarEmoji)
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 4) {
                Text(friend.nickname)
                    .font(.headlineMedium)
                    .foregroundStyle(.primaryText)

                HStack(spacing: 12) {
                    Label("Rank #\(friend.rank)", systemImage: "trophy.fill")
                        .font(.bodySmall)
                        .foregroundStyle(.secondaryText)

                    Text("•")
                        .foregroundStyle(.tertiaryText)

                    Text("\(formatNumber(friend.totalClicks)) clicks")
                        .font(.bodySmall)
                        .foregroundStyle(.secondaryText)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
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

// MARK: - Preview

#Preview {
    FriendsView()
}
