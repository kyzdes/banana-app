//
//  AppColors.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI

/// App color palette with Dark Mode support
extension Color {
    // MARK: - Banana Theme Colors

    /// Primary banana yellow
    static let bananaPrimary = Color("BananaPrimary", bundle: nil)

    /// Secondary cream color
    static let bananaSecondary = Color("BananaSecondary", bundle: nil)

    // MARK: - Accent Colors

    /// Success/Friend indicator green
    static let accentGreen = Color.green

    /// Error/Warning red
    static let accentRed = Color.red

    /// Info/Link blue
    static let accentBlue = Color.blue

    // MARK: - UI Colors

    /// Primary background
    static let appBackground = Color(uiColor: .systemBackground)

    /// Secondary background (cards, sections)
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)

    /// Tertiary background (grouped backgrounds)
    static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)

    /// Primary text
    static let primaryText = Color(uiColor: .label)

    /// Secondary text
    static let secondaryText = Color(uiColor: .secondaryLabel)

    /// Tertiary text
    static let tertiaryText = Color(uiColor: .tertiaryLabel)

    /// Separator/divider
    static let separator = Color(uiColor: .separator)

    // MARK: - Medal Colors

    static let goldMedal = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let silverMedal = Color(red: 0.75, green: 0.75, blue: 0.75)
    static let bronzeMedal = Color(red: 0.80, green: 0.50, blue: 0.20)

    // MARK: - Custom Initializer for Hex

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient Styles

extension LinearGradient {
    /// Banana gradient from top to bottom
    static let bananaGradient = LinearGradient(
        colors: [Color(hex: "#FFE66D"), Color(hex: "#FFD93D")],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Card gradient with blur effect
    static let cardGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.2),
            Color.white.opacity(0.1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
