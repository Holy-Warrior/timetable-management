# My Schedules

Manage your schedule like never before. Ditch your spreadsheets and upgrade to a premium, Material 3 experience designed for modern life.

## ✨ Features

- **Modern Material 3 UI**: A sleek, premium aesthetic with dynamic color schemes, "Outfit" typography, and glassmorphism-inspired design elements.
- **Intelligent Status Tracking**: 
  - Real-time "NOW" indicators for ongoing classes.
  - Precise countdowns for "Starts in X min" and "Ends in X min".
  - **Midnight-Aware**: Advanced logic to handle classes that cross midnight or week boundaries.
- **Smart Navigation**: Dynamic tab-based interface that automatically displays only the days with scheduled classes.
- **Advanced Notification System**:
  - **Custom Offsets**: Receive alerts exactly at class time or up to 60 minutes before.
  - **Professional Branding**: Custom alert channels with a unique notification sound and app icon.
  - **Reliable Persistence**: Alarms persist across device reboots with accurate local timezone scheduling.
- **Deep Customization**:
  - **Theme Support**: Choose between Light, Dark, or Automatic (System) appearance.
  - **Color Coding**: Organize your courses with a full-featured color picker.
- **Automated Updates**: Integrated GitHub release checker to keep you on the latest version.
- **Rock-Solid Foundation**: Comprehensive unit test suite ensuring CRUD logic and data persistence reliability.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Language**: [Dart](https://dart.dev/)
- **Architecture**: Provider (ChangeNotifier) for reactive state management.
- **Storage**: Persistent local storage via `shared_preferences`.
- **Time/Date**: `timezone` and `flutter_timezone` for cross-platform local time accuracy.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (Latest stable version recommended)
- Android Studio / VS Code with Flutter extension

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Holy-Warrior/timetable-management.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## 🧪 Testing

The app includes a dedicated logic test suite to ensure schedule calculations and settings persistence remain bug-free.

```bash
flutter test test/timetable_logic_test.dart
```

---
*My Schedules - Rethinking how you manage your day.*