//
//  Guild.swift
//  BananaClicker V2.0
//
//  Created by Claude on 2025-11-22.
//

import Foundation

/// Guild/Clan definition
struct Guild: Identifiable, Codable {
    let id: UUID
    let name: String
    let tag: String // 3-4 letter tag [TAG]
    var description: String
    let leaderId: UUID
    var members: [GuildMember]
    var level: Int
    var totalClicks: Int
    var createdAt: Date
    var bannerEmoji: String
    var isPublic: Bool
    var requirements: GuildRequirements

    struct GuildRequirements: Codable {
        var minTotalClicks: Int
        var minPrestigeLevel: Int
    }

    var memberCount: Int {
        members.count
    }

    var maxMembers: Int {
        25 + (level * 5) // Increases with guild level
    }

    mutating func addMember(_ member: GuildMember) -> Bool {
        guard members.count < maxMembers else { return false }
        members.append(member)
        return true
    }

    mutating func removeMember(userId: UUID) {
        members.removeAll { $0.userId == userId }
    }

    mutating func addClicks(_ clicks: Int) {
        totalClicks += clicks
        // Level up check
        let requiredForNextLevel = level * 100000
        if totalClicks >= requiredForNextLevel {
            level += 1
        }
    }
}

/// Guild member
struct GuildMember: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let nickname: String
    let avatarEmoji: String
    var role: GuildRole
    var contributedClicks: Int
    var joinedAt: Date
    var lastActive: Date

    enum GuildRole: String, Codable {
        case leader = "Leader"
        case officer = "Officer"
        case member = "Member"

        var permissions: [Permission] {
            switch self {
            case .leader:
                return [.invite, .kick, .promote, .editGuild, .startWar]
            case .officer:
                return [.invite, .kick]
            case .member:
                return []
            }
        }

        enum Permission {
            case invite
            case kick
            case promote
            case editGuild
            case startWar
        }
    }
}

/// Guild War event
struct GuildWar: Identifiable, Codable {
    let id: UUID
    let guild1Id: UUID
    let guild2Id: UUID
    var guild1Clicks: Int
    var guild2Clicks: Int
    let startTime: Date
    let endTime: Date
    var status: WarStatus
    var winnerId: UUID?

    enum WarStatus: String, Codable {
        case scheduled
        case active
        case finished
    }

    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    var isActive: Bool {
        status == .active && Date() >= startTime && Date() <= endTime
    }
}

/// Guild perk/bonus
struct GuildPerk: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let requiredLevel: Int
    let effect: PerkEffect

    enum PerkEffect {
        case clickBonus(Double)
        case xpBonus(Double)
        case questBonus(Double)
        case memberCapacity(Int)
    }

    static let allPerks: [GuildPerk] = [
        GuildPerk(
            id: "click_boost_1",
            name: "Guild Click Boost I",
            description: "+5% click power for all members",
            icon: "hand.tap.fill",
            requiredLevel: 1,
            effect: .clickBonus(0.05)
        ),
        GuildPerk(
            id: "click_boost_2",
            name: "Guild Click Boost II",
            description: "+10% click power for all members",
            icon: "hand.tap.fill",
            requiredLevel: 5,
            effect: .clickBonus(0.10)
        ),
        GuildPerk(
            id: "xp_boost",
            name: "Guild XP Boost",
            description: "+20% XP for all members",
            icon: "star.fill",
            requiredLevel: 3,
            effect: .xpBonus(0.20)
        ),
        GuildPerk(
            id: "quest_boost",
            name: "Guild Quest Boost",
            description: "+15% quest rewards",
            icon: "sparkles",
            requiredLevel: 7,
            effect: .questBonus(0.15)
        ),
        GuildPerk(
            id: "capacity_1",
            name: "Larger Guild I",
            description: "+10 member capacity",
            icon: "person.3.fill",
            requiredLevel: 2,
            effect: .memberCapacity(10)
        ),
        GuildPerk(
            id: "capacity_2",
            name: "Larger Guild II",
            description: "+20 member capacity",
            icon: "person.3.fill",
            requiredLevel: 10,
            effect: .memberCapacity(20)
        )
    ]
}
