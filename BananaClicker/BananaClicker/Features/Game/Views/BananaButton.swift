//
//  BananaButton.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI

/// Large tappable banana button with animations
struct BananaButton: View {
    let scale: CGFloat
    let rotation: Double
    let onTap: () -> Void

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.bananaPrimary.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .blur(radius: 20)

                // Banana emoji
                Text("🍌")
                    .font(.system(size: 150))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
        }
        .buttonStyle(BananaButtonStyle(scale: scale, rotation: rotation))
        .accessibilityLabel("Banana")
        .accessibilityHint("Tap to increase click count")
        .accessibilityAddTraits(.isButton)
    }
}

/// Custom button style for banana
struct BananaButtonStyle: ButtonStyle {
    let scale: CGFloat
    let rotation: Double

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1.0 : scale)
            .rotationEffect(reduceMotion ? .zero : .degrees(rotation))
            .animation(
                reduceMotion ? .linear(duration: 0.1) : .spring(response: 0.3, dampingFraction: 0.7),
                value: scale
            )
            .animation(
                reduceMotion ? .linear(duration: 0.1) : .spring(response: 0.3, dampingFraction: 0.7),
                value: rotation
            )
    }
}

// MARK: - Idle Pulse Animation

struct IdlePulseModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

extension View {
    func idlePulse() -> some View {
        modifier(IdlePulseModifier())
    }
}

// MARK: - Preview

#Preview {
    BananaButton(scale: 1.0, rotation: 0) {
        print("Banana tapped!")
    }
    .padding()
}
