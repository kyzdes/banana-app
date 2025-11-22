//
//  Quest.swift
//  BananaClicker V2.0
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import SwiftData

/// Daily quest data
@Model
final class QuestProgress {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var dailyQuests: [DailyQuest]
    var completedQuestIds: [String]
    var lastResetDate: Date
    var currentStreak: Int

    init(userId: UUID) {
        self.id = UUID()
        self.userId = userId
        self.dailyQuests = []
        self.completedQuestIds = []
        self.lastResetDate = Date()
        self.currentStreak = 0
        generateDailyQuests()
    }

    /// Generate 3 random daily quests
    func generateDailyQuests() {
        dailyQuests = Array(Quest.allQuests.shuffled().prefix(3)).map { quest in
            DailyQuest(quest: quest, progress: 0, isCompleted: false)
        }
    }

    /// Update quest progress
    func updateProgress(questId: String, progress: Int) {
        if let index = dailyQuests.firstIndex(where: { $0.quest.id == questId }) {
            dailyQuests[index].progress = progress

            if progress >= dailyQuests[index].quest.targetValue {
                dailyQuests[index].isCompleted = true
                completedQuestIds.append(questId)
            }
        }
    }

    /// Check if should reset daily quests
    func shouldResetQuests() -> Bool {
        let calendar = Calendar.current
        return !calendar.isDate(lastResetDate, inSameDayAs: Date())
    }

    /// Reset quests for new day
    func resetQuests() {
        lastResetDate = Date()

        // Check if all quests were completed
        let allCompleted = dailyQuests.allSatisfy { $0.isCompleted }
        if allCompleted {
            currentStreak += 1
        } else {
            currentStreak = 0
        }

        generateDailyQuests()
        completedQuestIds.removeAll()
    }
}

/// Daily quest instance
struct DailyQuest: Codable {
    let quest: Quest
    var progress: Int
    var isCompleted: Bool

    var progressPercentage: Double {
        Double(progress) / Double(quest.targetValue)
    }
}

/// Quest definition
struct Quest: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let targetValue: Int
    let rewards: QuestReward
    let type: QuestType

    enum QuestType: Codable {
        case clicks
        case pvpWins
        case friendVisits
        case upgrades
        case skinChanges
        case guildDonation
    }

    struct QuestReward: Codable {
        let clicks: Int
        let gems: Int
        let xp: Int
        let goldenBananas: Int
    }
}

// MARK: - Quest Catalog
extension Quest {
    static let allQuests: [Quest] = [
        // Click quests
        Quest(
            id: "click_1000",
            title: "Click Master",
            description: "Click 1,000 times",
            icon: "hand.tap.fill",
            targetValue: 1000,
            rewards: QuestReward(clicks: 500, gems: 10, xp: 100, goldenBananas: 0),
            type: .clicks
        ),
        Quest(
            id: "click_5000",
            title: "Click Champion",
            description: "Click 5,000 times",
            icon: "flame.fill",
            targetValue: 5000,
            rewards: QuestReward(clicks: 2000, gems: 25, xp: 250, goldenBananas: 1),
            type: .clicks
        ),

        // PvP quests
        Quest(
            id: "pvp_win_3",
            title: "Battle Victor",
            description: "Win 3 PvP battles",
            icon: "shield.fill",
            targetValue: 3,
            rewards: QuestReward(clicks: 1000, gems: 20, xp: 200, goldenBananas: 1),
            type: .pvpWins
        ),
        Quest(
            id: "pvp_win_10",
            title: "War Hero",
            description: "Win 10 PvP battles",
            icon: "star.fill",
            targetValue: 10,
            rewards: QuestReward(clicks: 5000, gems: 50, xp: 500, goldenBananas: 2),
            type: .pvpWins
        ),

        // Social quests
        Quest(
            id: "visit_friends",
            title: "Social Butterfly",
            description: "Visit 5 friends' profiles",
            icon: "person.2.fill",
            targetValue: 5,
            rewards: QuestReward(clicks: 800, gems: 15, xp: 150, goldenBananas: 0),
            type: .friendVisits
        ),

        // Upgrade quests
        Quest(
            id: "buy_upgrades",
            title: "Shopping Spree",
            description: "Purchase 3 upgrades",
            icon: "cart.fill",
            targetValue: 3,
            rewards: QuestReward(clicks: 1500, gems: 30, xp: 300, goldenBananas: 1),
            type: .upgrades
        ),

        // Collection quests
        Quest(
            id: "change_skin",
            title: "Fashion Forward",
            description: "Change your banana skin",
            icon: "paintbrush.fill",
            targetValue: 1,
            rewards: QuestReward(clicks: 500, gems: 10, xp: 100, goldenBananas: 0),
            type: .skinChanges
        )
    ]
}
