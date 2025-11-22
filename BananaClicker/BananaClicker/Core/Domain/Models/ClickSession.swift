//
//  ClickSession.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import SwiftData

/// Represents a single click session with all associated clicks
@Model
final class ClickSession {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var startTime: Date
    var endTime: Date?
    var totalClicks: Int
    var averageCPS: Double
    var isSynced: Bool

    @Relationship(deleteRule: .cascade)
    var clicks: [ClickRecord]

    init(userId: UUID) {
        self.id = UUID()
        self.userId = userId
        self.startTime = Date()
        self.endTime = nil
        self.totalClicks = 0
        self.averageCPS = 0
        self.isSynced = false
        self.clicks = []
    }

    /// Adds a new click to the session
    func addClick() {
        let clickNumber = totalClicks + 1
        let click = ClickRecord(clickNumber: clickNumber)
        clicks.append(click)
        totalClicks = clickNumber
        updateAverageCPS()
    }

    /// Calculates the average clicks per second for this session
    private func updateAverageCPS() {
        let duration = Date().timeIntervalSince(startTime)
        guard duration > 0 else {
            averageCPS = 0
            return
        }
        averageCPS = Double(totalClicks) / duration
    }

    /// Ends the session
    func endSession() {
        endTime = Date()
        updateAverageCPS()
    }
}

/// Represents a single click with timestamp
@Model
final class ClickRecord {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var clickNumber: Int
    var session: ClickSession?

    init(clickNumber: Int) {
        self.id = UUID()
        self.timestamp = Date()
        self.clickNumber = clickNumber
    }
}

// MARK: - API Models

/// Click batch for sending to server
struct ClickBatch: Codable, Sendable {
    let userId: UUID
    let clicks: [Click]
    let sessionId: UUID
    let deviceId: String
}

/// Single click data for API
struct Click: Codable, Sendable {
    let timestamp: Date
    let sessionClickNumber: Int
}
