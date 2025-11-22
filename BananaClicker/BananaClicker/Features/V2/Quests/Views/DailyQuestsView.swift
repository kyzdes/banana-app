//
//  DailyQuestsView.swift
//  BananaClicker V2.0
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI

struct DailyQuestsView: View {
    @Binding var questProgress: QuestProgress

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerView

                    // Quests
                    VStack(spacing: 12) {
                        ForEach(Array(questProgress.dailyQuests.enumerated()), id: \.element.quest.id) { index, dailyQuest in
                            QuestCard(
                                dailyQuest: dailyQuest,
                                questNumber: index + 1
                            )
                        }
                    }

                    // Streak info
                    streakView
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("📋 Daily Quests")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Complete daily quests for rewards!")
                .font(.bodyMedium)
                .foregroundStyle(.secondaryText)

            HStack(spacing: 20) {
                VStack {
                    Text("\(questProgress.dailyQuests.filter { $0.isCompleted }.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.bananaPrimary)

                    Text("Completed Today")
                        .font(.caption)
                        .foregroundStyle(.secondaryText)
                }

                Divider()
                    .frame(height: 40)

                VStack {
                    Text("\(questProgress.currentStreak)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.accentGreen)

                    Text("Day Streak")
                        .font(.caption)
                        .foregroundStyle(.secondaryText)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondaryBackground)
            )
        }
    }

    private var streakView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Streak Bonus")
                .font(.headlineMedium)
                .foregroundStyle(.primaryText)

            Text("Complete all quests daily to maintain your streak and earn bonus rewards!")
                .font(.bodySmall)
                .foregroundStyle(.secondaryText)

            HStack(spacing: 8) {
                ForEach(1...7, id: \.self) { day in
                    Circle()
                        .fill(questProgress.currentStreak >= day ? Color.accentGreen : Color.gray.opacity(0.3))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Text("\(day)")
                                .font(.caption2)
                                .foregroundStyle(.white)
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondaryBackground)
        )
    }
}

struct QuestCard: View {
    let dailyQuest: DailyQuest
    let questNumber: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: dailyQuest.quest.icon)
                    .font(.title2)
                    .foregroundStyle(dailyQuest.isCompleted ? .accentGreen : .bananaPrimary)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Quest \(questNumber)")
                            .font(.labelSmall)
                            .foregroundStyle(.secondaryText)

                        if dailyQuest.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.accentGreen)
                        }
                    }

                    Text(dailyQuest.quest.title)
                        .font(.headlineMedium)
                        .foregroundStyle(.primaryText)

                    Text(dailyQuest.quest.description)
                        .font(.bodySmall)
                        .foregroundStyle(.secondaryText)
                }

                Spacer()
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progress")
                        .font(.labelSmall)
                    Spacer()
                    Text("\(dailyQuest.progress) / \(dailyQuest.quest.targetValue)")
                        .font(.labelSmall)
                        .foregroundStyle(.bananaPrimary)
                }

                ProgressView(value: dailyQuest.progressPercentage)
                    .tint(dailyQuest.isCompleted ? .accentGreen : .bananaPrimary)
            }

            // Rewards
            HStack(spacing: 12) {
                if dailyQuest.quest.rewards.clicks > 0 {
                    RewardBadge(icon: "hand.tap.fill", value: "\(dailyQuest.quest.rewards.clicks)")
                }
                if dailyQuest.quest.rewards.gems > 0 {
                    RewardBadge(icon: "gem.fill", value: "\(dailyQuest.quest.rewards.gems)")
                }
                if dailyQuest.quest.rewards.xp > 0 {
                    RewardBadge(icon: "star.fill", value: "\(dailyQuest.quest.rewards.xp) XP")
                }
                if dailyQuest.quest.rewards.goldenBananas > 0 {
                    RewardBadge(icon: "banknote.fill", value: "\(dailyQuest.quest.rewards.goldenBananas)")
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(dailyQuest.isCompleted ? Color.accentGreen.opacity(0.1) : Color.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(dailyQuest.isCompleted ? Color.accentGreen : Color.clear, lineWidth: 2)
                )
        )
    }
}

struct RewardBadge: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(value)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color.bananaPrimary.opacity(0.2)))
        .foregroundStyle(.bananaPrimary)
    }
}

#Preview {
    @Previewable @State var progress = QuestProgress(userId: UUID())
    DailyQuestsView(questProgress: $progress)
}
