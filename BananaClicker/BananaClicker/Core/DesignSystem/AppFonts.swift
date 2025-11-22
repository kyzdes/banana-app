//
//  AppFonts.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI

/// App typography using SF Pro Rounded
extension Font {
    // MARK: - Display Fonts

    /// Extra large title (click counter)
    static var clickCounter: Font {
        Font.system(size: 72, weight: .bold, design: .rounded)
            .monospacedDigit()
    }

    /// Large display text
    static var displayLarge: Font {
        Font.system(.largeTitle, design: .rounded, weight: .bold)
    }

    /// Medium display text
    static var displayMedium: Font {
        Font.system(.title, design: .rounded, weight: .bold)
    }

    /// Small display text
    static var displaySmall: Font {
        Font.system(.title2, design: .rounded, weight: .semibold)
    }

    // MARK: - Headline Fonts

    /// Large headline
    static var headlineLarge: Font {
        Font.system(.title3, design: .rounded, weight: .semibold)
    }

    /// Medium headline
    static var headlineMedium: Font {
        Font.system(.headline, design: .rounded, weight: .semibold)
    }

    /// Small headline
    static var headlineSmall: Font {
        Font.system(.subheadline, design: .rounded, weight: .medium)
    }

    // MARK: - Body Fonts

    /// Large body text
    static var bodyLarge: Font {
        Font.system(.body, design: .default, weight: .regular)
    }

    /// Medium body text (default)
    static var bodyMedium: Font {
        Font.system(.callout, design: .default, weight: .regular)
    }

    /// Small body text
    static var bodySmall: Font {
        Font.system(.footnote, design: .default, weight: .regular)
    }

    // MARK: - Label Fonts

    /// Large label
    static var labelLarge: Font {
        Font.system(.subheadline, design: .default, weight: .medium)
    }

    /// Medium label
    static var labelMedium: Font {
        Font.system(.caption, design: .default, weight: .medium)
    }

    /// Small label
    static var labelSmall: Font {
        Font.system(.caption2, design: .default, weight: .regular)
    }

    // MARK: - Special Fonts

    /// Monospaced numbers (for stats)
    static var statsNumber: Font {
        Font.system(.title3, design: .rounded, weight: .bold)
            .monospacedDigit()
    }

    /// Rank number
    static var rankNumber: Font {
        Font.system(.title2, design: .rounded, weight: .heavy)
            .monospacedDigit()
    }
}

// MARK: - Text Styles

struct AppTextStyle {
    /// Hero title style
    static func heroTitle(_ text: String) -> some View {
        Text(text)
            .font(.displayLarge)
            .foregroundStyle(.primaryText)
    }

    /// Section header style
    static func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headlineLarge)
            .foregroundStyle(.primaryText)
    }

    /// Stat value style
    static func statValue(_ value: String) -> some View {
        Text(value)
            .font(.statsNumber)
            .foregroundStyle(.bananaPrimary)
    }

    /// Subtitle style
    static func subtitle(_ text: String) -> some View {
        Text(text)
            .font(.bodyMedium)
            .foregroundStyle(.secondaryText)
    }
}
