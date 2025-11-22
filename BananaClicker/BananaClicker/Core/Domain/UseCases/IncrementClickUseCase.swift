//
//  IncrementClickUseCase.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import SwiftData
import OSLog

/// Use case for handling click increments with rate limiting and sync
@Observable
final class IncrementClickUseCase {
    private let clickRepository = ClickRepository.shared
    private let hapticManager = HapticManager.shared
    private let soundManager = SoundManager.shared
    private let logger = Logger(subsystem: "com.yourcompany.bananaclicker", category: "IncrementClick")

    // Anti-cheat rate limiting
    private var clickTimestamps: [Date] = []
    private var pendingClicks: [Click] = []
    private var currentSessionId = UUID()

    // Sync state
    private var lastSyncTime: Date?
    private var syncTask: Task<Void, Never>?

    func execute(userId: UUID, modelContext: ModelContext) async -> Bool {
        // Rate limiting check
        let now = Date()
        clickTimestamps.append(now)

        // Remove timestamps older than 1 second
        let oneSecondAgo = now.addingTimeInterval(-1)
        clickTimestamps.removeAll { $0 < oneSecondAgo }

        // Check if exceeding rate limit
        if clickTimestamps.count > Constants.ClickLimits.maxClicksPerSecond {
            logger.warning("Rate limit exceeded: \(clickTimestamps.count) clicks per second")
            hapticManager.playErrorHaptic()
            return false
        }

        // Add click to local storage
        let clickNumber = pendingClicks.count + 1
        let click = Click(timestamp: now, sessionClickNumber: clickNumber)
        pendingClicks.append(click)

        // Play feedback
        hapticManager.playClickHaptic()
        soundManager.playClickSound()

        // Check for milestone
        checkMilestone(clickNumber: clickNumber)

        // Sync if needed (every 10 clicks or 5 seconds)
        if pendingClicks.count >= Constants.ClickLimits.clickBatchSize ||
           shouldSync() {
            await syncClicks(userId: userId)
        }

        logger.debug("Click registered: #\(clickNumber)")
        return true
    }

    private func checkMilestone(clickNumber: Int) {
        if Constants.Milestones.clickMilestones.contains(clickNumber) {
            logger.info("Milestone reached: \(clickNumber) clicks")
            hapticManager.playMilestoneHaptic()
            soundManager.playMilestoneSound()
        }
    }

    private func shouldSync() -> Bool {
        guard let lastSync = lastSyncTime else {
            return true
        }
        return Date().timeIntervalSince(lastSync) >= Constants.ClickLimits.clickSyncInterval
    }

    private func syncClicks(userId: UUID) async {
        guard !pendingClicks.isEmpty else { return }

        let clicksToSync = pendingClicks
        pendingClicks.removeAll()
        lastSyncTime = Date()

        let deviceId = await UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let batch = ClickBatch(
            userId: userId,
            clicks: clicksToSync,
            sessionId: currentSessionId,
            deviceId: deviceId
        )

        do {
            try await clickRepository.submitClickBatch(batch)
            logger.info("Synced \(clicksToSync.count) clicks to server")
        } catch {
            logger.error("Failed to sync clicks: \(error.localizedDescription)")
            // Re-add failed clicks to pending
            pendingClicks.insert(contentsOf: clicksToSync, at: 0)
        }
    }

    /// Force sync all pending clicks
    func forceSync(userId: UUID) async {
        await syncClicks(userId: userId)
    }

    /// Get pending clicks count
    var pendingClicksCount: Int {
        pendingClicks.count
    }
}
