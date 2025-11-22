//
//  BananaClickerApp.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import SwiftUI
import SwiftData

@main
struct BananaClickerApp: App {
    @State private var authManager = AuthenticationManager.shared

    // SwiftData model container
    let modelContainer: ModelContainer = {
        let schema = Schema([
            ClickSession.self,
            ClickRecord.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier(Constants.AppGroup.identifier)
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isLoading {
                    // Loading screen
                    ZStack {
                        LinearGradient.bananaGradient
                            .ignoresSafeArea()

                        VStack(spacing: 20) {
                            Text("🍌")
                                .font(.system(size: 100))

                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)

                            Text("V2.0")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                    }
                } else if authManager.isAuthenticated {
                    // Main app - V2.0!
                    MainTabViewV2()
                        .modelContainer(modelContainer)
                } else {
                    // Login screen
                    LoginView()
                }
            }
            .environment(authManager)
        }
    }
}
