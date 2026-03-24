# 📸 EventShot

Welcome to **EventShot**, an incredibly fast, strictly-typed Flutter application built for real-time, offline-first collaborative event photography! 

This application was designed using robust enterprise-grade engineering patterns, but it's organized to be highly approachable.

---

## Getting Started

Follow these quick steps to get EventShot running on your local machine -

### Prerequisites
1. **Flutter SDK**: Make sure you have the Flutter SDK installed on your machine (`flutter --version` should return `>= 3.10.8`).
2. **Firebase Account**: The backend routing requires Firebase.

### Installation Walkthrough

1. **Clone the repository**

```bash
   git clone https://github.com/michael-alu/eventshot_mobile.git

   cd eventshot_mobile
```

2. **Install Flutter Dependencies**

Run exactly this command in your terminal to fetch Riverpod, GoRouter, Firebase, and everything else we need!
   
   ```bash
   flutter pub get
   ```

3. **Connecting Firebase (Critical Step)**
   
Since this is a Firebase-backed app, it requires server configuration files to boot successfully. Talk to our Lead Developer (Michael) to get the local setup keys:
   - **Android**: Place `google-services.json` into the `android/app` folder.
   - **iOS**: Place `GoogleService-Info.plist` into the `ios/Runner` folder.

4. **Run the App!**

Fire up your Android Emulator or iOS Simulator and run:
   ```bash
   flutter run
   ```

---

## Architecture Guide

We separated our code using **Clean Architecture** to make it super easy to understand. We don't throw everything into one massive `main.dart`!

* **`lib/features/`** 

Here you will find isolated feature spheres (like `/auth`, `/attendee`, `/events`). Each feature has its own `presentation` (UI), `domain` (business logic/entities), and `data` (database repositories) folders.
* **`lib/core/`** 

Shared routing logic, Theme setup, and DI injection.
* **State Management** 

We use **Riverpod**. If you see `ref.watch()` in the code, it means the UI is actively listening to a reactive data stream! We actively avoid using `setState()` spaghetti here. The UI updates natively whenever the data changes.

### Understanding the Back-End
EventShot utilizes a **NoSQL Firestore Database** tightly bound to our ERD. We enforce strict Firebase Security Rules that verify ownership (e.g., an Organizer is the only one who can delete their event gallery).

**Key Flow -**
* Guests can instantly sign up anonymously via QR codes to snap photos.
* Our `OfflineUploadManager` intelligently queues images using `SharedPreferences` to disk if the Wi-Fi connection drops, pushing them safely to the cloud once network continuity restores!

---

## Testing

We take test-driven development seriously to ensure no production bugs slip into the main branch. To run our suite of automated widget regression tests:

```bash
flutter test
```
(Current Branch Coverage: 26/26 Tests Passing - 100% Success!)