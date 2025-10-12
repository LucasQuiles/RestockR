
# RestockR

RestockR is a Flutter application that helps collectors and retail operators keep track of hot product restocks, subscribe to watchlists, and monitor inventory trends across multiple retailers.

## Requirements

- Flutter SDK ^3.29.2
- Dart SDK
- Android Studio or VS Code with Flutter tooling
- Android SDK (and/or Xcode for iOS builds)

## Getting Started

1. Fetch dependencies:

   ```bash
   flutter pub get
   ```

2. Run the app on a connected device or emulator:

   ```bash
   flutter run
   ```

## Project Structure

```
RestockR/
├── android/                         # Android-specific configuration
├── ios/                             # iOS-specific configuration
├── lib/
│   ├── core/                        # Shared exports, helpers, and utilities
│   ├── presentation/                # Feature screens and widgets
│   ├── routes/                      # Route definitions and navigation map
│   ├── theme/                       # Theme, color, and text-style helpers
│   ├── widgets/                     # Reusable UI components
│   └── main.dart                    # Application entry point
├── assets/                          # Images, fonts, and static resources
├── pubspec.yaml                     # Dependencies and Flutter config
└── README.md
```

## Running Tests

```bash
flutter test
```

## Production Builds

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Notes

- Update the `applicationId` in `android/app/build.gradle` and bundle identifiers in `ios/Runner.xcodeproj` if you need platform-specific IDs.
- Review `lib/core/app_export.dart` and `lib/routes/app_routes.dart` before adding new screens to keep navigation consistent.
