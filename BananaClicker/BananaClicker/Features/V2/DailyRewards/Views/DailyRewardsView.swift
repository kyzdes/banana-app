//
//  DailyRewardsView.swift
//  BananaClicker V2.0
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI

struct DailyRewardsView: View {
    @Binding var rewardProgress: DailyRewardProgress
    @Binding var onClaim: (DailyReward) -> Void

    @State private var showCelebration = false

    var body: some View {
        VStack(spacing: 24) {
            // Header
            headerView

            // Rewards calendar
            VStack(spacing: 12) {
                ForEach(Array(DailyReward.rewards.enumerated()), id: \.element.day) { index, reward in
                    DailyRewardRow(
                        reward: reward,
                        dayNumber: index + 1,
                        isClaimed: !rewardProgress.canClaimToday() && (rewardProgress.currentStreak % 7) > index,
                        isToday: rewardProgress.canClaimToday() && (rewardProgress.currentStreak % 7) == index,
                        onClaim: {
                            if let claimed = rewardProgress.claimReward() {
                                onClaim(claimed)
                                showCelebration = true
                                HapticManager.shared.playSuccessHaptic()
                            }
                        }
                    )
                }
            }

            // Streak info
            streakInfoView
        }
        .padding()
        .confettiCannon(counter: $showCelebration, num: 50, radius: 300)
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("🎁")
                .font(.system(size: 60))

            Text("Daily Login Rewards")
                .font(.displayMedium)
                .foregroundStyle(.primaryText)

            Text("Login every day to claim amazing rewards!")
                .font(.bodyMedium)
                .foregroundStyle(.secondaryText)
                .multilineTextAlignment(.center)
        }
    }

    private var streakInfoView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Current Streak")
                        .font(.bodySmall)
                        .foregroundStyle(.secondaryText)

                    Text("\(rewardProgress.currentStreak) Days")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.accentGreen)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Best Streak")
                        .font(.bodySmall)
                        .foregroundStyle(.secondaryText)

                    Text("\(rewardProgress.longestStreak) Days")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.bananaPrimary)
                }
            }

            if !rewardProgress.canClaimToday() {
                Text("Come back tomorrow for your next reward!")
                    .font(.bodySmall)
                    .foregroundStyle(.secondaryText)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondaryBackground)
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondaryBackground)
        )
    }
}

struct DailyRewardRow: View {
    let reward: DailyReward
    let dayNumber: Int
    let isClaimed: Bool
    let isToday: Bool
    let onClaim: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Day indicator
            ZStack {
                Circle()
                    .fill(circleColor)
                    .frame(width: 50, height: 50)

                if isClaimed {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.white)
                } else {
                    Text("\(dayNumber)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }

            // Rewards
            VStack(alignment: .leading, spacing: 4) {
                Text("Day \(dayNumber)")
                    .font(.headlineMedium)
                    .foregroundStyle(.primaryText)

                HStack(spacing: 8) {
                    RewardBadge(icon: "hand.tap.fill", value: "\(reward.clicks)")
                    RewardBadge(icon: "gem.fill", value: "\(reward.gems)")

                    if reward.goldenBananas > 0 {
                        RewardBadge(icon: "banknote.fill", value: "\(reward.goldenBananas)")
                    }

                    if let special = reward.specialReward {
                        switch special {
                        case .skin:
                            Image(systemName: "paintbrush.fill")
                                .foregroundStyle(.purple)
                        case .multiplier:
                            Image(systemName: "bolt.fill")
                                .foregroundStyle(.orange)
                        case .powerUp:
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                }
            }

            Spacer()

            // Claim button
            if isToday {
                Button(action: onClaim) {
                    Text("Claim")
                        .font(.headlineMedium)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(LinearGradient.bananaGradient)
                        )
                        .foregroundStyle(.white)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isToday ? Color.bananaPrimary.opacity(0.1) : Color.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isToday ? Color.bananaPrimary : Color.clear, lineWidth: 2)
                )
        )
    }

    private var circleColor: Color {
        if isClaimed {
            return .accentGreen
        } else if isToday {
            return .bananaPrimary
        } else {
            return .gray
        }
    }
}

// Simple confetti modifier placeholder
extension View {
    func confettiCannon(counter: Binding<Bool>, num: Int, radius: CGFloat) -> some View {
        self
    }
}

#Preview {
    @Previewable @State var progress = DailyRewardProgress(userId: UUID())
    @Previewable @State var onClaim: (DailyReward) -> Void = { _ in }

    DailyRewardsView(rewardProgress: $progress, onClaim: $onClaim)
}
