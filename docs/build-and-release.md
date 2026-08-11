# Build and Release

Required: Flutter 3.44.9 stable, Dart 3.12.2, Android SDK/Java 17, and Xcode on macOS for iOS.

```sh
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --flavor dev --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://10.0.2.2:3000
flutter build apk --release --flavor prod --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://api.example.com
```

Android provides `dev`, `staging`, and `prod` product flavors with distinct identifiers. iOS uses the production bundle identifier `com.seat.customer`; matching Xcode schemes/configurations must be finalized and signed on macOS before TestFlight. Never commit credentials, signing keys, API secrets, FCM/APNs configuration, or production URLs.

Pre-release checklist: configure the production API URL, release signing, FCM/APNs provider, final app icon/logo, Inter/Noto Sans Arabic assets, privacy/legal URLs, and physical-device accessibility/RTL QA.
