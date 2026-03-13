# EventShot

The simplest way to collect and share photos from your event in real-time.

## Features

- **Organizers**: Create events, select pricing tiers, manage attendees, and view all photos in real-time.
- **Attendees**: Join events instantly via QR code or 6-digit pin. No app download or account required to participate.
- **Shared Gallery**: Real-time photo syncing where everyone at the event can see, like, and download memories.

## Technical Stack

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod (v2)
- **Routing**: GoRouter
- **Backend & Auth**: Firebase (Authentication, Firestore, Storage)
- **Architecture**: Feature-first Clean Architecture

## Getting Started

1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Configure your Firebase project using the `flutterfire` CLI.
   ```bash
   flutterfire configure
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Design System

The app uses a custom Material 3 theme matching our Figma prototypes. It features:
- Dark navy background palette (`#101922` and `#1C2127`)
- Primary brand accent (`#137FEC`)
- Soft, glassy borders matching modern iOS design trends
- Clean, rounded button UI with standardized sizing across the app

## Project Structure

```text
lib/
  ├── bootstrap/              # App initialization and Firebase setup
  ├── core/                   # Shared theme, routing, error handling
  ├── features/               # Feature slices (Auth, Events, Checkout, Gallery, etc.)
  │   └── [feature_name]/     
  │       ├── data/           # Models, DTOs, Repository Implementations
  │       ├── domain/         # Entities, Repository Interfaces
  │       └── presentation/   # UI Screens, Widgets, Riverpod Providers
  ├── shared/                 # Reusable UI components (Buttons, Inputs, Cards)
  └── main.dart               # Entry point
```
