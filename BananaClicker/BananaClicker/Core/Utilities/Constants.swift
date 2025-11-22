//
//  Constants.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation

/// App-wide constants
enum Constants {
    /// Click rate limiting
    enum ClickLimits {
        static let maxClicksPerSecond = 20
        static let clickBatchSize = 10
        static let clickSyncInterval: TimeInterval = 5
    }

    /// Friend limits
    enum Friends {
        static let maxFriends = 100
    }

    /// Leaderboard configuration
    enum Leaderboard {
        static let defaultPageSize = 100
        static let autoRefreshInterval: TimeInterval = 30
    }

    /// Nickname validation
    enum Nickname {
        static let minLength = 3
        static let maxLength = 20
        static let changeInterval: TimeInterval = 30 * 24 * 3600 // 30 days
    }

    /// Achievements (for Game Center)
    enum Achievements {
        static let novice = "com.yourcompany.bananaclicker.novice" // 100 clicks
        static let enthusiast = "com.yourcompany.bananaclicker.enthusiast" // 1,000 clicks
        static let master = "com.yourcompany.bananaclicker.master" // 10,000 clicks
        static let legend = "com.yourcompany.bananaclicker.legend" // 100,000 clicks
        static let marathoner = "com.yourcompany.bananaclicker.marathoner" // 1,000 clicks in a day
        static let sprinter = "com.yourcompany.bananaclicker.sprinter" // 100 clicks per minute
        static let socialButterfly = "com.yourcompany.bananaclicker.social" // 10 friends
    }

    /// Milestones for special effects
    enum Milestones {
        static let clickMilestones = [100, 500, 1_000, 5_000, 10_000, 50_000, 100_000, 500_000, 1_000_000]
    }

    /// Animation durations
    enum Animation {
        static let clickAnimation: TimeInterval = 0.2
        static let scaleEffect: Double = 1.1
        static let rotationRange: Double = 10 // degrees
        static let numberCounterDuration: TimeInterval = 0.5
    }

    /// URLs
    enum URLs {
        static let privacyPolicy = "https://bananaclicker.app/privacy"
        static let termsOfService = "https://bananaclicker.app/terms"
        static let support = "https://bananaclicker.app/support"
    }

    /// App Group (for widgets)
    enum AppGroup {
        static let identifier = "group.com.yourcompany.bananaclicker"
    }
}
