# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Olympsis is a comprehensive iOS application with companion watchOS app focused on sports activities, event management, and social features for athletes and sports communities.

## Build Commands

### Main iOS App
```bash
# Build main iOS app
xcodebuild -scheme Olympsis -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Build for device
xcodebuild -scheme Olympsis -configuration Debug -destination 'platform=iOS,name=iPhone'

# Build for release/archive
xcodebuild -scheme Olympsis -configuration Release archive -archivePath ./build/Olympsis.xcarchive
```

### watchOS App
```bash
# Build watchOS app (requires paired iOS app)
xcodebuild -scheme OlympsisWatchkit -configuration Debug -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

### Quick Development
```bash
# Open in Xcode
open Olympsis.xcodeproj

# Clean build folder
xcodebuild clean -scheme Olympsis
```

## Architecture

### Multi-Target Structure
The project consists of three main targets:
- **Olympsis** - Main iOS app
- **OlympsisWatchkit** - watchOS companion app
- **Olympsis Live Events** - App extension for live events/widgets

### Technology Stack
- **Framework**: SwiftUI with some UIKit integration
- **Language**: Swift (Xcode 16.0 compatible)
- **Backend**: Firebase (Auth, Analytics, Cloud Messaging)
- **Dependencies**: Swift Package Manager
- **Health Integration**: HealthKit for workout tracking
- **Location**: CoreLocation for GPS tracking
- **Image Processing**: Kingfisher for image loading/caching

### Key Dependencies
- Firebase iOS SDK (v10.29.0) - Authentication, analytics, push notifications
- Kingfisher (v7.12.0) - Image downloading and caching
- Hermes (v0.2.3) - Custom networking library

## Directory Structure

### Main App (`/Olympsis/`)
- `Components/` - Reusable UI components organized by feature
- `Views/` - Main application views and screens
- `Data/` - Data layer (models, services, observers, managers)
- `Shared/` - Components shared between iOS and watchOS targets
- `Utils/` - Utility functions and helpers
- `Assets.xcassets/` - Images, colors, and assets
- `Locatlization/` - String catalogs for internationalization

### watchOS App (`/Olympsis-Watchkit/`)
- `Components/` - Watch-specific UI components
- `Views/` - Watch application views (Running, General, Preparation)

### Shared Code (`/Shared/`)
- `Components/` - UI components shared between targets
- `Data/` - Shared data models and workout management
- `WorkoutManager+` extensions - Modular workout functionality

## Core Features

### 1. Multi-Tab Architecture
- Home (dashboard with events, venues, announcements)
- Groups/Clubs (social community features)
- Events (sports event management)
- Activities (workout tracking)
- Profile (user management)

### 2. Workout & Activity Tracking
- HealthKit integration for workout data
- GPS tracking via CoreLocation
- Multi-sport support (running, cycling, general sports)
- Shared `WorkoutManager` between iOS and watchOS
- Real-time workout metrics and splits

### 3. Event Management System
- Create and manage sports events
- RSVP functionality and participant management
- Event sharing and social features
- Location-based event discovery

### 4. Social Features
- Groups/clubs with membership management
- User profiles and social interactions
- In-app messaging and chat system
- Feed system for posts and updates

## Key Architectural Patterns

### State Management
- Uses SwiftUI's `@StateObject` and `@ObservableObject`
- Custom `SessionStore` for global state management
- Router-based navigation for each main section

### Modular Design
- Clean separation between UI components and business logic
- Shared components between iOS and watchOS targets
- Service-oriented architecture for API calls
- Feature-based component organization

### Data Flow
- Observers for reactive data updates (`AuthObserver`, `EventObserver`, etc.)
- Services for API communication (`AuthService`, `EventService`, etc.)
- Managers for feature-specific logic (`WorkoutManager`, `EventManager`, etc.)

## Working with Shared Code

### WorkoutManager System
The `WorkoutManager` is split into extensions:
- `WorkoutManager+Read.swift` - Reading workout data
- `WorkoutManager+Write.swift` - Writing workout data
- `WorkoutManager+Session.swift` - Session management
- `WorkoutManager+Location.swift` - GPS tracking
- `WorkoutManager+Helpers.swift` - Utility functions
- `WorkoutManager+PaceAnalysis.swift` - Performance analysis

### Shared Components
Components in `/Shared/` are available to both iOS and watchOS targets. When creating new shared functionality, place it here to avoid duplication.

## Configuration

### Bundle Configuration
- **Bundle ID**: `com.olympsis.client`
- **Custom URL Scheme**: `olympsis://`
- **Permissions**: HealthKit, Location, Notifications
- **Background Modes**: Location, remote notifications, background fetch

### Localization
- Uses `.xcstrings` files for internationalization
- Organized by feature (Activities, Events, General, etc.)
- Located in `Locatlization/Catalogues/`

### Custom Fonts
- Uses Archivo font family with multiple weights and styles
- Located in `Fonts/` directory

## Development Notes

### Firebase Integration
- `GoogleService-Info.plist` contains Firebase configuration
- Authentication, analytics, and push notifications are integrated
- Services are abstracted through custom service layer

### HealthKit Integration
- Workout tracking capabilities across multiple sports
- Real-time metrics and data synchronization
- Requires HealthKit permissions for full functionality

### Location Services
- GPS tracking for outdoor activities
- Location-based event discovery
- Venue mapping and search functionality

### Testing
- No active test targets (removed from project)
- Use simulator for testing different device configurations
- Test both iOS and watchOS components when working with shared code