# Memos Note - Overview

A Flutter client for [Memos](https://github.com/usememos/memos) - An open source, self-hosted note taking and knowledge base application.

## Core Features

- **Memo Management**: Create, edit, and delete markdown-based notes
- **Comments**: Add comments to memos
- **Sharing**: Share memos with others via links
- **Offline Support**: Works offline with automatic sync when back online
- **Multi-language**: Supports English and Indonesian (extensible)
- **Deep Links**: Open memos directly via `memos://app/memo/:id`
- **Cross-platform**: Android, iOS, Web, macOS, Windows, Linux

## Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.5+ |
| State Management | Riverpod (flutter_riverpod + riverpod_annotation) |
| Navigation | GoRouter 14 |
| HTTP Client | Dio 5 |
| Local Database | SQLite (sqflite) |
| Local Storage | SharedPreferences, Flutter Secure Storage |
| Markdown | flutter_markdown |
| UI Components | CachedNetworkImage, Shimmer, StaggeredGridView |

## Architecture

The project follows **Clean Architecture** principles:

```
lib/
├── core/           # Core utilities, theme, constants
├── data/           # Data layer (models, repositories, API, local DB)
├── domain/         # Domain layer (entities, repositories, use cases)
├── presentation/   # Presentation layer (screens, widgets)
├── l10n/           # Localization files
└── main.dart
```

### Layer Responsibilities

| Layer | Responsibility |
|-------|----------------|
| **Presentation** | Screens, widgets, and Riverpod providers |
| **Data** | Repositories, models, local DAOs, remote API, sync service |
| **Domain** | Business logic (entities, repository interfaces, use cases) |
| **Core** | Shared utilities, constants, theming, routing |

## Offline-First Pattern

The app implements an **offline-first architecture**:

1. All writes go to local SQLite first
2. Pending operations are queued for sync
3. When connectivity restores, sync service processes the queue
4. Reads prioritizes local cache when offline

```
User Action → Repository
              ├── Online? → API → Server → Local DB → UI
              └── Offline? → Local DB + Pending Ops Queue → UI
                                              ↓
                           Network restores → SyncService processes queue
```