# SEAT Mobile

Production Flutter customer application for SEAT V1 restaurant discovery and reservation requests in Bahrain. This repository contains only the customer app; restaurant staff remains a separate future application.

## Run locally

Install Flutter 3.44.9 stable, then:

```sh
flutter pub get
flutter run --flavor dev --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

The backend URL must point to SEAT API 0.12.0 or newer. No secrets belong in Dart defines or source control; provider secrets live in platform deployment configuration.

For an isolated development preview with deterministic Bahrain fixture data:

```sh
flutter run --flavor dev --dart-define=APP_ENV=dev --dart-define=ENABLE_DEV_FIXTURES=true

Staging, with fixtures disabled:

```bash
flutter run --flavor dev --dart-define-from-file=dart_defines/staging.json
```
```

Sign in with `+97330000000` and OTP `123456`. Fixture mode is deliberately rejected for staging and production builds.

## Quality

```sh
flutter analyze
flutter test
flutter build apk --flavor dev --dart-define=APP_ENV=dev
```

See [architecture](docs/architecture.md), [API integration](docs/api-integration.md), [localization](docs/localization.md), and [build/release](docs/build-and-release.md).
