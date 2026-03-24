# Architecture Documentation

## Directory Structure

```
lib/
├── main.dart                          # App entry point
├── core/                              # Core infrastructure
│   ├── constants/
│   │   └── app_constants.dart         # App-wide constants
│   ├── di/
│   │   └── providers.dart             # Riverpod providers (DI container)
│   ├── providers/
│   │   └── locale_provider.dart       # Locale state management
│   ├── router/
│   │   └── app_router.dart            # GoRouter configuration
│   ├── theme/
│   │   └── app_theme.dart             # Light/Dark theme definitions
│   └── utils/
│       ├── jwt_utils.dart             # JWT token decoder
│       └── storage_service.dart       # SharedPrefs & SecureStorage wrapper
├── data/                              # Data layer
│   ├── models/                        # Data models (DTOs)
│   │   ├── memo_model.dart
│   │   ├── memo_model.g.dart
│   │   ├── user_model.dart
│   │   ├── user_model.g.dart
│   │   ├── comment_model.dart
│   │   └── comment_model.g.dart
│   ├── repositories/
│   │   └── memos_repository.dart      # Main repository (offline-first)
│   ├── remote/                         # Remote data sources
│   │   ├── api/
│   │   │   └── memos_api.dart         # REST API client (Dio)
│   │   └── interceptors/
│   │       └── dio_interceptors.dart  # Auth & logging interceptors
│   ├── local/                          # Local data sources
│   │   ├── db/
│   │   │   └── local_database.dart    # SQLite database setup
│   │   └── dao/
│   │       ├── memo_dao.dart          # Memo CRUD operations
│   │       └── pending_ops_dao.dart   # Offline operation queue
│   └── sync/
│       └── sync_service.dart          # Background sync logic
├── presentation/                       # UI layer
│   └── screens/
│       ├── home/
│       │   └── home_screen.dart       # Main memo list view
│       ├── editor/
│       │   └── editor_screen.dart     # Create/Edit memo
│       ├── detail/
│       │   ├── memo_detail_screen.dart # View memo details
│       │   └── shared_memo_screen.dart # View shared memos
│       ├── login/
│       │   └── login_screen.dart      # Authentication
│       ├── instance_setup/
│       │   └── instance_setup_screen.dart # Server URL setup
│       ├── profile/
│       │   └── profile_screen.dart    # User profile & settings
│       └── comments/
│           └── comments_screen.dart   # View/Add comments
└── l10n/                              # Internationalization
    ├── app_localizations.dart         # Generated base class
    ├── app_localizations_en.dart      # English translations
    ├── app_localizations_id.dart      # Indonesian translations
    ├── app_en.arb                     # English ARB source
    └── app_id.arb                     # Indonesian ARB source
```

## Riverpod Provider Hierarchy

```
ProviderScope (root)
├── routerProvider (GoRouter)
│   ├── authStateProvider (watched for redirects)
│   └── localeProvider (watched for language)
├── memosRepositoryProvider
├── syncServiceProvider
├── authStateProvider (AuthNotifier)
├── memosProvider (MemosNotifier)
├── syncStatusProvider (SyncStatusNotifier)
├── connectivityProvider (StreamProvider<bool>)
├── tagsProvider (FutureProvider<Map<String, int>>)
├── commentsProvider.family(String memoName)
├── memoDetailProvider.family(String memoName)
├── memoSharesProvider.family(String memoName)
└── sharedMemoProvider.family(String shareId)
```

## Data Flow

### Offline-First Memo Creation

1. Create temp memo with `local_{timestamp}` ID
2. Save to SQLite with `is_local_only = 1`
3. Enqueue `PendingOp(PendingOpType.create, ...)`
4. If online → push to server, replace temp ID, clear pending
5. If offline → return local version (synced later when network restores)

### Authentication Flow

1. User enters credentials/PAT
2. `AuthNotifier.signIn()` calls repository
3. Repository authenticates with API
4. Token stored in secure storage
5. User cached in SharedPreferences for offline access
6. Router redirects to `/home`

### Sync Flow

1. Connectivity changes to online
2. `SyncStatusNotifier` triggers `processPendingOps()`
3. For each `PendingOp` in queue:
   - create → POST to server, replace temp ID
   - update → PATCH content
   - delete → DELETE from server
   - uploadAttachment → POST file, link to memo
4. On success → delete from pending_ops
5. On failure → increment retry count (max 3 retries)