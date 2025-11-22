//
//  GameView.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI
import SwiftData

/// Main game view with banana clicker
struct GameView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = GameViewModel()

    // Mock user ID (in real app, from authentication)
    private let userId = UUID()

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.appBackground
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    LoadingView()
                } else {
                    ScrollView {
                        VStack(spacing: 30) {
                            // Header with rank
                            headerView

                            // Main click counter
                            clickCounterView

                            // Banana button
                            bananaButtonView

                            // Quick stats
                            quickStatsView

                            Spacer(minLength: 50)
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Banana Clicker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        Text("Profile") // ProfileView will be created next
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.bananaPrimary)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.goldMedal)
                        Text("#\(viewModel.rank)")
                            .font(.headlineMedium)
                            .foregroundStyle(.primaryText)
                    }
                }
            }
        }
    }

    // MARK: - View Components

    private var headerView: some View {
        HStack {
            if let user = viewModel.currentUser {
                Text(user.avatarEmoji)
                    .font(.system(size: 40))

                VStack(alignment: .leading) {
                    Text(user.nickname)
                        .font(.headlineLarge)
                        .foregroundStyle(.primaryText)

                    Text("Rank #\(viewModel.rank)")
                        .font(.bodySmall)
                        .foregroundStyle(.secondaryText)
                }
            }

            Spacer()
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

            Text("🍌 clicks")
                .font(.headlineMedium)
                .foregroundStyle(.secondaryText)

            // Plus one animation
            if viewModel.showPlusOne {
                Text("+1")
                    .font(.title)
                    .foregroundStyle(.accentGreen)
                    .offset(y: viewModel.plusOneOffset)
                    .opacity(viewModel.showPlusOne ? 1 : 0)
                    .transition(.opacity)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }

    private var bananaButtonView: some View {
        BananaButton(
            scale: viewModel.bananaScale,
            rotation: viewModel.bananaRotation
        ) {
            Task {
                await viewModel.handleClick(userId: userId, modelContext: modelContext)
            }
        }
        .idlePulse()
        .padding(.vertical, 20)
    }

    private var quickStatsView: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "CPS",
                value: viewModel.formattedCPS,
                icon: "speedometer"
            )

            StatCard(
                title: "Session",
                value: viewModel.formattedSessionClicks,
                icon: "chart.line.uptrend.xyaxis"
            )

            StatCard(
                title: "Pending",
                value: "\(viewModel.pendingClicksCount)",
                icon: "arrow.up.circle"
            )
        }
    }
}

// MARK: - Preview

#Preview {
    GameView()
        .modelContainer(for: ClickSession.self, inMemory: true)
}
