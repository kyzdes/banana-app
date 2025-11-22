# 🍌 Banana Clicker - iOS App

A minimalist social clicker game with banana theme for iOS 18.0+.

## Overview

Banana Clicker is a social clicker game where players compete to see who can click the most bananas. The app features:

- **Engaging Gameplay**: Simple tap mechanics with satisfying haptic feedback and animations
- **Social Features**: Add friends, compare scores, and compete on leaderboards
- **Global Competition**: Climb the global, regional, and weekly leaderboards
- **Game Center Integration**: Unlock achievements and track your progress
- **Beautiful UI**: Native iOS design with SwiftUI, supporting both Light and Dark modes

## Technical Stack

### Core Technologies
- **Language**: Swift 6.0
- **UI Framework**: SwiftUI (100% native UI)
- **Architecture**: MVVM + Clean Architecture
- **Concurrency**: Swift Concurrency (async/await, actors)
- **Navigation**: NavigationStack (iOS 16+)

### Apple Frameworks
- **SwiftUI** - Modern declarative UI
- **SwiftData** - Local data persistence
- **Observation** - Reactive state management (@Observable)
- **AuthenticationServices** - Sign in with Apple
- **GameKit** - Leaderboards and achievements (planned)
- **CoreHaptics** - Tactile feedback
- **AVFoundation** - Sound effects
- **Charts** - Activity visualization
- **WidgetKit** - Home screen widget (planned)
- **UserNotifications** - Daily reminders (planned)

## Architecture

The app follows Clean Architecture principles with three main layers:

```
┌─────────────────────────────────────┐
│        Presentation Layer           │
│    (SwiftUI Views + ViewModels)     │
└─────────────────────────────────────┘
                 ↓↑
┌─────────────────────────────────────┐
│         Domain Layer                │
│    (Use Cases, Business Logic)      │
└─────────────────────────────────────┘
                 ↓↑
┌─────────────────────────────────────┐
│          Data Layer                 │
│  (Repositories, Network, Storage)   │
└─────────────────────────────────────┘
```

### Project Structure

```
BananaClicker/
├── App/
│   ├── Authentication/
│   │   ├── AuthenticationManager.swift
│   │   └── LoginView.swift
│   ├── BananaClickerApp.swift
│   └── MainTabView.swift
│
├── Core/
│   ├── Domain/
│   │   ├── Models/
│   │   │   ├── User.swift
│   │   │   ├── ClickSession.swift
│   │   │   ├── LeaderboardEntry.swift
│   │   │   └── Friend.swift
│   │   └── UseCases/
│   │       ├── IncrementClickUseCase.swift
│   │       ├── FetchLeaderboardUseCase.swift
│   │       └── AddFriendUseCase.swift
│   │
│   ├── Data/
│   │   ├── Repositories/
│   │   ├── Network/
│   │   └── Storage/
│   │
│   ├── DesignSystem/
│   │   ├── AppColors.swift
│   │   ├── AppFonts.swift
│   │   └── AppComponents.swift
│   │
│   └── Utilities/
│       ├── HapticManager.swift
│       ├── SoundManager.swift
│       ├── KeychainManager.swift
│       └── Constants.swift
│
├── Features/
│   ├── Game/
│   │   ├── Views/
│   │   │   ├── GameView.swift
│   │   │   └── BananaButton.swift
│   │   └── ViewModels/
│   │       └── GameViewModel.swift
│   │
│   ├── Leaderboard/
│   │   ├── Views/
│   │   └── ViewModels/
│   │
│   ├── Friends/
│   │   ├── Views/
│   │   └── ViewModels/
│   │
│   └── Profile/
│       ├── Views/
│       └── ViewModels/
│
└── Resources/
    └── Assets.xcassets
```

## Features

### MVP Features (Phase 1) ✅
- ✅ Sign in with Apple authentication
- ✅ Core click mechanics with haptic feedback
- ✅ Local progress saving with SwiftData
- ✅ Beautiful banana animations
- ✅ Global leaderboard
- ✅ Friends system
- ✅ User profile and statistics
- ✅ Settings (haptics, sound effects)

### Planned Features (Future Phases) 🔄
- 🔄 Game Center integration
- 🔄 Achievements system
- 🔄 Activity charts
- 🔄 Home screen widget
- 🔄 Challenge mode between friends
- 🔄 Power-ups and boosters
- 🔄 Seasonal events
- 🔄 Banana skins customization
- 🔄 Apple Watch companion app

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 6.0+

## Setup

1. Clone the repository
2. Open `BananaClicker.xcodeproj` in Xcode
3. Configure your development team in the project settings
4. Update the bundle identifier to match your team
5. Enable "Sign in with Apple" capability
6. Build and run on your device or simulator

## Backend API

The app requires a backend API server. The base URL is configured in `APIClient.swift`:

```swift
private let baseURL = URL(string: "https://api.bananaclicker.app/v1")!
```

### Required Endpoints

See `Endpoints.swift` for a complete list of API endpoints.

## Anti-Cheat

The app implements several anti-cheat measures:

- Client-side rate limiting (max 20 clicks/second)
- Server-side validation of all clicks
- Device fingerprinting
- Timestamp validation
- Batch submission tracking

## Privacy & Security

- **Authentication**: Sign in with Apple (OAuth 2.0)
- **Token Storage**: iOS Keychain
- **API Communication**: HTTPS only
- **Data Collection**: Minimal (nickname, clicks, friend list)
- **No Tracking**: App does not track users across apps/websites

## Testing

### Unit Tests
Run unit tests for business logic:
```bash
⌘ + U in Xcode
```

### UI Tests
Run UI tests for user flows:
```bash
⌘ + U with UI Test scheme
```

## Contributing

This project follows standard Swift coding conventions and SwiftUI best practices.

## License

[Your License Here]

## Credits

Developed with ❤️ using SwiftUI and modern iOS technologies.

---

**Version**: 1.0 (1)
**Last Updated**: 2025-11-22
