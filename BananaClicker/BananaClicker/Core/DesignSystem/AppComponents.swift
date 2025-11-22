//
//  AppComponents.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI

// MARK: - Card Component

/// Glassmorphic card with blur effect
struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.secondaryBackground.opacity(0.8))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            )
    }
}

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.headlineMedium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient.bananaGradient)
            )
            .foregroundColor(.black)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Secondary Button

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.headlineMedium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.bananaPrimary, lineWidth: 2)
            )
            .foregroundColor(.bananaPrimary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.bananaPrimary)

            Text(value)
                .font(.statsNumber)
                .foregroundStyle(.primaryText)

            Text(title)
                .font(.labelSmall)
                .foregroundStyle(.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondaryBackground)
        )
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading...")
                .font(.bodyMedium)
                .foregroundStyle(.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

// MARK: - Error View

struct ErrorView: View {
    let error: Error
    let retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.accentRed)

            Text("Oops!")
                .font(.displayMedium)
                .foregroundStyle(.primaryText)

            Text(error.localizedDescription)
                .font(.bodyMedium)
                .foregroundStyle(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let retryAction = retryAction {
                PrimaryButton("Try Again", icon: "arrow.clockwise") {
                    retryAction()
                }
                .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.secondaryText)

            Text(title)
                .font(.displayMedium)
                .foregroundStyle(.primaryText)

            Text(message)
                .font(.bodyMedium)
                .foregroundStyle(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(actionTitle) {
                    action()
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

// MARK: - Preview Helpers

#Preview("Glass Card") {
    GlassCard {
        VStack {
            Text("Glass Card")
                .font(.headlineLarge)
            Text("With blur effect")
                .font(.bodySmall)
        }
    }
    .padding()
}

#Preview("Buttons") {
    VStack(spacing: 20) {
        PrimaryButton("Primary Button", icon: "star.fill") {}
        SecondaryButton("Secondary Button", icon: "heart") {}
    }
    .padding()
}

#Preview("Stat Card") {
    StatCard(title: "Clicks", value: "1,234", icon: "hand.tap.fill")
        .padding()
}
