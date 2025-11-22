//
//  LeaderboardRowView.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI

/// Row view for a single leaderboard entry
struct LeaderboardRowView: View {
    let entry: LeaderboardEntry

    var body: some View {
        HStack(spacing: 16) {
            // Rank with medal
            rankView

            // Avatar
            Text(entry.avatarEmoji)
                .font(.system(size: 40))

            // User info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(entry.nickname)
                        .font(.headlineMedium)
                        .foregroundStyle(.primaryText)

                    if entry.isFriend {
                        Image(systemName: "circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.accentGreen)
                    }

                    if entry.isCurrentUser {
                        Text("YOU")
                            .font(.labelSmall)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.bananaPrimary)
                            )
                            .foregroundStyle(.black)
                    }
                }

                Text(entry.formattedClicks + " clicks")
                    .font(.bodySmall)
                    .foregroundStyle(.secondaryText)
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiaryText)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(entry.isCurrentUser ? Color.bananaPrimary.opacity(0.1) : Color.secondaryBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(entry.isCurrentUser ? Color.bananaPrimary : Color.clear, lineWidth: 2)
        )
    }

    @ViewBuilder
    private var rankView: some View {
        ZStack {
            if let medal = entry.medalEmoji {
                // Top 3 - show medal
                Text(medal)
                    .font(.system(size: 30))
            } else {
                // Others - show rank number
                Text("#\(entry.rank)")
                    .font(.rankNumber)
                    .foregroundStyle(.secondaryText)
                    .frame(width: 60)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        LeaderboardRowView(entry: LeaderboardEntry.previewData[0])
        LeaderboardRowView(entry: LeaderboardEntry.previewData[1])
        LeaderboardRowView(entry: LeaderboardEntry.previewData[5])
    }
    .padding()
}
