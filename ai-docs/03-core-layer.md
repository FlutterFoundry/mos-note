# Core Layer Documentation

## app_constants.dart

App-wide constants used throughout the application.

### Values

| Constant | Value | Description |
|----------|-------|-------------|
| `appName` | `'Memos Note'` | App display name |
| `apiVersion` | `'/api/v1'` | API endpoint version |
| `defaultTimeout` | `30000` | HTTP timeout in ms |
| `pageSize` | `20` | Pagination size |
| `deepLinkScheme` | `'memos'` | Deep link protocol |
| `dbName` | `'memos_note.db'` | SQLite database name |
| `dbVersion` | `3` | Database schema version |

## app_router.dart

GoRouter configuration with authentication-aware routing.

### Routes

| Path | Screen | Auth Required |
|------|--------|---------------|
| `/instance-setup` | InstanceSetupScreen | No |
| `/login` | LoginScreen | No |
| `/home` | HomeScreen | Yes |
| `/memo/:name` | MemoDetailScreen | Yes |
| `/editor` | EditorScreen | Yes |
| `/editor/:name` | EditorScreen | Yes |
| `/memo/:name/comments` | CommentsScreen | Yes |
| `/profile` | ProfileScreen | Yes |
| `/s/:shareId` | SharedMemoScreen | No |

### Redirect Logic

```dart
// Redirect to instance setup if no instance configured
if (!hasInstance) return '/instance-setup';

// Redirect to login if not authenticated (for protected routes)
if (requiresAuth && !isLoggedIn) return '/login';

// Redirect to home if authenticated and on login/setup
if (isLoggedIn && (onLogin || onSetup)) return '/home';
```

## providers.dart (DI Container)

Dependency injection using Riverpod providers.

### Repository Providers

```dart
final memosRepositoryProvider = Provider<MemosRepository>((ref) {
  final api = ref.watch(memosApiProvider);
  final db = ref.watch(localDatabaseProvider);
  return MemosRepository(api, db);
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final repo = ref.watch(memosRepositoryProvider);
  return SyncService(repo);
});
```

### State Notifiers

#### AuthNotifier

Manages authentication state with offline fallback.

```dart
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  // Methods
  Future<void> signIn(String username, String password);
  Future<void> signInWithToken(String token);
  Future<void> signOut();
  Future<void> checkAuth();
}
```

#### MemosNotifier

CRUD operations for memos with sync integration.

```dart
class MemosNotifier extends StateNotifier<AsyncValue<List<MemoModel>>> {
  // Methods
  Future<void> load();
  Future<void> create(MemoModel memo);
  Future<void> update(MemoModel memo);
  Future<void> delete(String name);
  Future<void> syncAll();
  Future<void> processPendingOps();
}
```

#### SyncStatusNotifier

Tracks pending sync operations.

```dart
class SyncStatusNotifier extends StateNotifier<int> {
  // state = count of pending operations
  Future<void> refresh();
}
```

### Future Providers

```dart
// Network connectivity stream
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (result) => result.isNotEmpty,
  );
});

// Tag statistics
final tagsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.watch(memosRepositoryProvider);
  return repo.listTags();
});

// Single memo (family provider)
final memoDetailProvider = FutureProvider.family<MemoModel?, String>((ref, name) {
  final repo = ref.watch(memosRepositoryProvider);
  return repo.getMemo(name);
});
```

## storage_service.dart

Wrapper for `SharedPreferences` and `FlutterSecureStorage`.

### Key Methods

```dart
class StorageService {
  // Secure storage operations
  Future<void> setSecureString(String key, String value);
  Future<String?> getSecureString(String key);
  Future<void> deleteSecure(String key);

  // Preferences operations
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);

  // User caching for offline
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<bool> hasOfflineCredentials();
}
```

### Storage Keys

| Key | Storage | Purpose |
|-----|---------|---------|
| `instance_url` | Preferences | Memos server URL |
| `token` | Secure | Auth token |
| `cached_user` | Preferences | User for offline access |
| `locale` | Preferences | User language preference |

## app_theme.dart

Material 3 theme definitions.

### Color Palette

```dart
class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color background = Color(0xFFFAFAFA);
  static const Color darkBackground = Color(0xFF111827);
  // ... more colors
}
```

### Theme Builder

```dart
class AppTheme {
  static ThemeData lightTheme();
  static ThemeData darkTheme();
}
```

### Context Extension

```dart
extension AppColorsExtension on BuildContext {
  Color get primary => Theme.of(this).colorScheme.primary;
  Color get background => Theme.of(this).scaffoldBackgroundColor;
}
```

## locale_provider.dart

Manages app locale persistence.

```dart
class LocaleNotifier extends StateNotifier<Locale?> {
  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('id'),
  ];

  Future<void> setLocale(Locale locale);
  Locale? getLocale();
}
```

## jwt_utils.dart

Utility for decoding JWT tokens.

```dart
Map<String, dynamic>? decodeJwt(String token);
```

Extracts payload without signature verification. Used for extracting user info from tokens.