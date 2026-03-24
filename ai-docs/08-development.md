# Development Guide

## Prerequisites

- Flutter SDK 3.5+
- Dart SDK ^3.5.0
- Android Studio / VS Code with Flutter extension

## Getting Started

### Installation

```bash
# Clone repository
git clone https://github.com/sheenazien8/mos-note.git
cd mos-note

# Install dependencies
flutter pub get

# Generate code (Riverpod, JSON serialization)
flutter pub run build_runner build
```

### Running

```bash
# Debug mode
flutter run

# Specific platform
flutter run -d chrome    # Web
flutter run -d macos     # macOS
flutter run -d android   # Android emulator
```

## Build Commands

```bash
# Android
flutter build apk              # APK
flutter build appbundle        # App Bundle (AAB)

# iOS
flutter build ios              # iOS app

# Web
flutter build web              # Web app

# Desktop
flutter build macos            # macOS app
flutter build windows          # Windows app
flutter build linux            # Linux app
```

## Code Generation

```bash
# Generate once
flutter pub run build_runner build

# Watch and regenerate on changes
flutter pub run build_runner watch

# Clean and rebuild
flutter pub run build_runner build --delete-conflicting-outputs
```

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/path/to/test.dart

# Run with coverage
flutter test --coverage
```

## Project Structure Conventions

### File Naming

- Screens: `*_screen.dart`
- Widgets: `*_widget.dart` or descriptive name
- Models: `*_model.dart`
- Providers: `*_provider.dart` or in `providers.dart`
- DAOs: `*_dao.dart`

### Class Naming

- Models: `MemoModel`, `UserModel`
- Screens: `HomeScreen`, `LoginScreen`
- Providers: `memosProvider`, `authStateProvider`
- Notifiers: `AuthNotifier`, `MemosNotifier`

### Import Order

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. External packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 4. Internal packages
import 'package:memos_note/core/...';
import 'package:memos_note/data/...';
```

## Debugging

### Logging

```dart
import 'dart:developer' as developer;

developer.log('Message', name: 'tag');
```

### Dio Interceptors

Logging interceptor provides network debugging:

```dart
void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
  developer.log('${options.method} ${options.uri}', name: 'API');
  handler.next(options);
}
```

### Database Inspection

```dart
// In local_database.dart, enable verbose logging
void _logQuery(String sql, List<dynamic> args) {
  developer.log('SQL: $sql | Args: $args', name: 'DB');
}
```

## Linting

The project uses `flutter_lints` with custom rules in `analysis_options.yaml`.

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    avoid_print: true
    prefer_single_quotes: true
    sort_constructors_first: true
```

## CI/CD

### GitHub Actions

Located in `.github/workflows/`

**Triggers:**

- Push tags matching `v*`
- Manual workflow dispatch

**Requirements:**

Configure GitHub secrets:

| Secret | Purpose |
|--------|---------|
| `KEYSTORE_BASE64` | Base64 encoded keystore |
| `KEYSTORE_PASSWORD` | Keystore password |
| `KEY_PASSWORD` | Key password |
| `KEY_ALIAS` | Key alias |

**Outputs:**

- APK (debug/release)
- App Bundle (AAB)

## Common Tasks

### Adding a New Screen

1. Create screen file in `lib/presentation/screens/`
2. Add route in `lib/core/router/app_router.dart`
3. Create provider if needed in `lib/core/di/providers.dart`
4. Link from existing screens

### Adding a New API Endpoint

1. Add method to `MemosApi` class
2. Add corresponding method to `MemosRepository`
3. Create/modify model if needed
4. Add notifier provider for UI state

### Adding Offline Support

1. Add pending op type to `PendingOpType` enum
2. Add handling in `SyncService._handleXxx()`
3. Queue operation in repository method
4. Update related DAO if needed

### Adding Localization

1. Add keys to `lib/l10n/app_en.arb`
2. Add translations to `lib/l10n/app_id.arb` (and other locales)
3. Run `flutter gen-l10n`
4. Use in code: `AppLocalizations.of(context)!.keyName`

## Troubleshooting

### Build Errors

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Database Errors

```bash
# Reset local database (during development)
# Delete app and reinstall, or:
await localDatabase.close();
await deleteDatabase(path);
```

### Sync Issues

If sync fails repeatedly:

1. Check API connectivity
2. Verify token validity
3. Check pending ops in database
4. Clear pending ops if stuck