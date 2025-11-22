//
//  SoundManager.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import AVFoundation
import OSLog

/// Manages sound effects throughout the app
@Observable
final class SoundManager: Sendable {
    static let shared = SoundManager()

    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private let logger = Logger(subsystem: "com.yourcompany.bananaclicker", category: "Sound")

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "sound_enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "sound_enabled") }
    }

    private init() {
        // Default to enabled
        if UserDefaults.standard.object(forKey: "sound_enabled") == nil {
            UserDefaults.standard.set(true, forKey: "sound_enabled")
        }

        setupAudioSession()
        preloadSounds()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            logger.info("Audio session configured")
        } catch {
            logger.error("Failed to setup audio session: \(error.localizedDescription)")
        }
    }

    private func preloadSounds() {
        // Note: In a real app, these would be actual sound files
        // For now, we'll use system sounds
        logger.info("Sound system initialized")
    }

    /// Play click sound
    func playClickSound() {
        guard isEnabled else { return }

        // Play system sound (can be replaced with custom sound)
        AudioServicesPlaySystemSound(1104) // Tock sound
    }

    /// Play milestone achievement sound
    func playMilestoneSound() {
        guard isEnabled else { return }

        // Play system sound
        AudioServicesPlaySystemSound(1025) // Achievement sound
    }

    /// Play success sound
    func playSuccessSound() {
        guard isEnabled else { return }

        AudioServicesPlaySystemSound(1054) // Success sound
    }

    /// Play error sound
    func playErrorSound() {
        guard isEnabled else { return }

        AudioServicesPlaySystemSound(1053) // Error sound
    }

    /// Play custom sound file
    func playSound(named name: String, volume: Float = 1.0) {
        guard isEnabled else { return }

        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            logger.warning("Sound file not found: \(name)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.prepareToPlay()
            player.play()

            audioPlayers[name] = player
            logger.info("Playing sound: \(name)")
        } catch {
            logger.error("Failed to play sound \(name): \(error.localizedDescription)")
        }
    }

    /// Stop all sounds
    func stopAllSounds() {
        audioPlayers.values.forEach { $0.stop() }
        audioPlayers.removeAll()
        logger.info("Stopped all sounds")
    }
}
