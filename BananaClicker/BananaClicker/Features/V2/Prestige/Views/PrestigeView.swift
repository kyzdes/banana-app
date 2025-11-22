//
//  PrestigeView.swift
//  BananaClicker V2.0
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI

struct PrestigeView: View {
    @State private var viewModel = PrestigeViewModel()
    let currentClicks: Int
    let onPrestige: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Prestige header
                    prestigeHeaderView

                    // Current stats
                    if let data = viewModel.prestigeData {
                        currentStatsView(data: data)

                        // Prestige button
                        prestigeButtonView(data: data)

                        // Perks
                        perksView(data: data)
                    }
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("✨ Prestige")
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog("Prestige Reset", isPresented: $viewModel.showConfirmation) {
                Button("Prestige", role: .destructive) {
                    _ = viewModel.performPrestige()
                    onPrestige()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You will lose all clicks but gain permanent bonuses. Continue?")
            }
        }
        .onAppear {
            viewModel.checkPrestigeEligibility(currentClicks: currentClicks)
        }
    }

    private var prestigeHeaderView: some View {
        VStack(spacing: 16) {
            Text("🌟")
                .font(.system(size: 80))

            Text("Ascend to Greater Power")
                .font(.displayMedium)
                .foregroundStyle(.primaryText)
                .multilineTextAlignment(.center)

            Text("Reset your clicks to gain permanent multipliers and Golden Bananas")
                .font(.bodyMedium)
                .foregroundStyle(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private func currentStatsView(data: PrestigeData) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Level",
                    value: "\(data.prestigeLevel)",
                    icon: "star.fill"
                )

                StatCard(
                    title: "Total",
                    value: "\(data.totalPrestiges)",
                    icon: "sparkles"
                )
            }

            HStack(spacing: 12) {
                StatCard(
                    title: "Multiplier",
                    value: String(format: "%.1fx", data.prestigeMultiplier),
                    icon: "bolt.fill"
                )

                StatCard(
                    title: "Golden 🍌",
                    value: "\(data.goldenBananas)",
                    icon: "banknote.fill"
                )
            }
        }
    }

    private func prestigeButtonView(data: PrestigeData) -> some View {
        VStack(spacing: 12) {
            let required = data.clicksForNextPrestige()
            let progress = Double(currentClicks) / Double(required)

            ProgressView(value: progress) {
                HStack {
                    Text("Progress to Next Prestige")
                        .font(.bodyMedium)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.bodyMedium)
                        .foregroundStyle(.bananaPrimary)
                }
            }
            .tint(.bananaPrimary)

            Text("\(formatNumber(currentClicks)) / \(formatNumber(required))")
                .font(.labelMedium)
                .foregroundStyle(.secondaryText)

            if viewModel.canPrestige {
                Button {
                    viewModel.showConfirmation = true
                } label: {
                    Label("Prestige Now", systemImage: "arrow.up.circle.fill")
                        .font(.headlineMedium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.purple, Color.pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            } else {
                Text("Keep clicking to unlock prestige!")
                    .font(.bodyMedium)
                    .foregroundStyle(.secondaryText)
                    .padding()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondaryBackground)
        )
    }

    private func perksView(data: PrestigeData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Prestige Perks")
                .font(.headlineLarge)
                .foregroundStyle(.primaryText)

            ForEach(PrestigePerk.allPerks) { perk in
                PerkRowView(
                    perk: perk,
                    currentLevel: data.prestigePerks[perk.id] ?? 0,
                    goldenBananas: data.goldenBananas,
                    onPurchase: {
                        _ = viewModel.purchasePerk(perk.id)
                    }
                )
            }
        }
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

struct PerkRowView: View {
    let perk: PrestigePerk
    let currentLevel: Int
    let goldenBananas: Int
    let onPurchase: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: perk.icon)
                .font(.title2)
                .foregroundStyle(.bananaPrimary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(perk.name)
                        .font(.headlineMedium)
                        .foregroundStyle(.primaryText)

                    Text("Lv. \(currentLevel)/\(perk.maxLevel)")
                        .font(.labelSmall)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.bananaPrimary.opacity(0.2)))
                        .foregroundStyle(.bananaPrimary)
                }

                Text(perk.description)
                    .font(.bodySmall)
                    .foregroundStyle(.secondaryText)
            }

            Spacer()

            if currentLevel < perk.maxLevel {
                let cost = perk.costPerLevel * (currentLevel + 1)
                Button {
                    onPurchase()
                } label: {
                    VStack(spacing: 4) {
                        Text("\(cost)")
                            .font(.labelLarge)
                        Image(systemName: "banknote.fill")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(goldenBananas >= cost ? Color.bananaPrimary : Color.gray)
                    )
                    .foregroundStyle(.white)
                }
                .disabled(goldenBananas < cost)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.accentGreen)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondaryBackground)
        )
    }
}

#Preview {
    PrestigeView(currentClicks: 500000) {}
}
