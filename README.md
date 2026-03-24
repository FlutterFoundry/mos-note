<div align="center">
  <img src="assets/images/mos_notes_icon.png" alt="Memos Note Icon" width="128">
</div>

# Memos Note

A Flutter client for [Memos](https://github.com/usememos/memos) - An open source, self-hosted note taking and knowledge base application.

## Features

- **Memo Management**: Create, edit, and delete markdown-based notes
- **Comments**: Add comments to memos
- **Sharing**: Share memos with others via links
- **Offline Support**: Works offline with automatic sync when back online
- **Multi-language**: Supports English and Indonesian (extensible)
- **Deep Links**: Open memos directly via `memos://app/memo/:id`
- **Cross-platform**: Android, iOS, Web, macOS, Windows, Linux

## Tech Stack

- **Framework**: Flutter 3.5+
- **State Management**: Riverpod (flutter_riverpod + riverpod_annotation)
- **Navigation**: GoRouter 14
- **HTTP Client**: Dio 5
- **Local Database**: SQLite (sqflite)
- **Local Storage**: SharedPreferences, Flutter Secure Storage
- **Markdown Rendering**: flutter_markdown
- **UI Components**: CachedNetworkImage, Shimmer, StaggeredGridView

## Architecture

The project follows Clean Architecture principles:

```
lib/
├── core/           # Core utilities, theme, constants
├── data/           # Data layer (models, repositories, API, local DB)
├── domain/         # Domain layer (entities, repositories, use cases)
├── presentation/   # Presentation layer (screens, widgets)
├── l10n/           # Localization files
└── main.dart
```

- **Presentation**: Screens and widgets with Riverpod providers
- **Data**: Repositories, models, local DAOs, remote API, sync service
- **Domain**: Business logic layer (entities, repository interfaces, use cases)

## Getting Started

### Prerequisites

- Flutter SDK 3.5+
- Dart SDK ^3.5.0

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/sheenazien8/mos-note.git
   cd mos-note
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Generate code (Riverpod, JSON serialization)
   ```bash
   flutter pub run build_runner build
   ```

4. Run the app
   ```bash
   flutter run
   ```

## Configuration

### Instance Setup

On first launch, the app requires configuring a Memos instance URL. The app connects to a [Memos](https://github.com/usememos/memos) backend server.

### Authentication

The app supports credential-based authentication. Tokens are securely stored using `flutter_secure_storage`.

## Project Structure

### Key Screens

| Screen | Path | Description |
|--------|------|-------------|
| Instance Setup | `/instance-setup` | Configure backend server URL |
| Login | `/login` | User authentication |
| Home | `/home` | List of memos with staggered grid |
| Editor | `/editor`, `/editor/:name` | Create or edit memos |
| Memo Detail | `/memo/:name` | View memo details |
| Comments | `/memo/:name/comments` | View and add comments |
| Profile | `/profile` | User profile |
| Shared Memo | `/s/:shareId` | View shared memo |

### State Management

The app uses Riverpod for reactive state management:

- `authStateProvider` - Authentication state
- `localeProvider` - Locale/language state
- Repository providers for API and local data

### Offline & Sync

- Local SQLite database for offline memo storage
- Sync service monitors connectivity and syncs pending operations
- Pending operations queue for offline-first architecture

## Localization

The app supports multiple languages. To add a new language:

1. Add language code to `l10n.yaml`
2. Create `lib/l10n/app_localizations_<code>.arb`
3. Add translations
4. Run `flutter gen-l10n`

Supported languages:
- English (`en`)
- Indonesian (`id`)

## CI/CD

The project includes GitHub Actions workflow for Android builds:

- **Trigger**: Push tags (`v*`) or manual dispatch
- **Outputs**: APK or App Bundle (AAB)
- **Requirements**: Configure GitHub secrets:
  - `KEYSTORE_BASE64`
  - `KEYSTORE_PASSWORD`
  - `KEY_PASSWORD`
  - `KEY_ALIAS`

## Development

### Build Commands

```bash
flutter run                    # Run in debug mode
flutter build apk              # Build Android APK
flutter build appbundle        # Build Android App Bundle
flutter build ios              # Build iOS
flutter build web              # Build for web
```

### Code Generation

```bash
flutter pub run build_runner build    # Generate code once
flutter pub run build_runner watch     # Watch and regenerate
```

### Testing

```bash
flutter test
```

## Dependencies

See [pubspec.yaml](pubspec.yaml) for the complete list of dependencies.

Key dependencies:
- `flutter_riverpod` - State management
- `go_router` - Declarative routing
- `dio` - HTTP client with interceptors
- `sqflite` - Local SQLite database
- `flutter_markdown` - Markdown rendering
- `connectivity_plus` - Network connectivity
- `timeago` - Relative time formatting

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open source. See the LICENSE file for details.

## Acknowledgments

- [Memos](https://github.com/usememos/memos) - Backend server
- [Flutter](https://flutter.dev) - UI framework