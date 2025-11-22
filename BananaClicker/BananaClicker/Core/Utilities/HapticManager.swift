//
//  HapticManager.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import UIKit
import CoreHaptics
import OSLog

/// Manages haptic feedback throughout the app
@Observable
final class HapticManager: Sendable {
    static let shared = HapticManager()

    private var engine: CHHapticEngine?
    private let logger = Logger(subsystem: "com.yourcompany.bananaclicker", category: "Haptics")

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "haptics_enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "haptics_enabled") }
    }

    private init() {
        // Default to enabled
        if UserDefaults.standard.object(forKey: "haptics_enabled") == nil {
            UserDefaults.standard.set(true, forKey: "haptics_enabled")
        }

        prepareHaptics()
    }

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            logger.warning("Device does not support haptics")
            return
        }

        do {
            engine = try CHHapticEngine()
            try engine?.start()

            // Reset engine on stop
            engine?.resetHandler = { [weak self] in
                self?.logger.info("Haptic engine reset")
                do {
                    try self?.engine?.start()
                } catch {
                    self?.logger.error("Failed to restart haptic engine: \(error.localizedDescription)")
                }
            }

            logger.info("Haptic engine initialized successfully")
        } catch {
            logger.error("Failed to create haptic engine: \(error.localizedDescription)")
        }
    }

    /// Light haptic feedback for regular clicks
    func playClickHaptic() {
        guard isEnabled else { return }

        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.prepare()
        impact.impactOccurred(intensity: 0.7)
    }

    /// Medium haptic for button taps
    func playTapHaptic() {
        guard isEnabled else { return }

        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.prepare()
        impact.impactOccurred()
    }

    /// Success haptic for achievements and milestones
    func playSuccessHaptic() {
        guard isEnabled else { return }

        let notification = UINotificationFeedbackGenerator()
        notification.prepare()
        notification.notificationOccurred(.success)
    }

    /// Error haptic for failures
    func playErrorHaptic() {
        guard isEnabled else { return }

        let notification = UINotificationFeedbackGenerator()
        notification.prepare()
        notification.notificationOccurred(.error)
    }

    /// Custom haptic pattern for milestone celebrations
    func playMilestoneHaptic() {
        guard isEnabled, let engine = engine else {
            playSuccessHaptic()
            return
        }

        do {
            // Create a celebratory haptic pattern
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)

            var events: [CHHapticEvent] = []

            // Triple tap pattern
            for i in 0..<3 {
                let time = TimeInterval(i) * 0.1
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: time
                )
                events.append(event)
            }

            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)

            logger.info("Played milestone haptic pattern")
        } catch {
            logger.error("Failed to play milestone haptic: \(error.localizedDescription)")
            playSuccessHaptic()
        }
    }

    /// Selection haptic for UI interactions
    func playSelectionHaptic() {
        guard isEnabled else { return }

        let selection = UISelectionFeedbackGenerator()
        selection.prepare()
        selection.selectionChanged()
    }
}
