# Dependencies Reference

## pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x
  
  # Navigation
  go_router: ^14.x
  
  # HTTP Client
  dio: ^5.x
  
  # Local Storage
  sqflite: ^2.x
  shared_preferences: ^2.x
  flutter_secure_storage: ^9.x
  path_provider: ^2.x
  
  # Connectivity
  connectivity_plus: ^5.x
  
  # UI Components
  flutter_markdown: ^0.x
  flutter_html: ^3.x
  cached_network_image: ^3.x
  shimmer: ^3.x
  flutter_staggered_grid_view: ^0.x
  
  # Media
  image_picker: ^1.x
  
  # Sharing
  share_plus: ^7.x
  
  # Utilities
  timeago: ^3.x
  intl: ^0.x
  uuid: ^4.x
  
  # JSON Serialization
  json_annotation: ^4.x
  
  # Deep Links
  app_links: ^3.x

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.x
  build_runner: ^2.x
  json_serializable: ^6.x
  riverpod_generator: ^2.x
```

## Key Dependencies

### State Management

**flutter_riverpod**

- Reactive state management
- Provider pattern implementation
- StateNotifier for complex state

**riverpod_annotation**

- Code generation for providers
- `@riverpod` annotations

### Navigation

**go_router**

- Declarative routing
- Deep link support
- Redirect logic for auth

### HTTP Client

**dio**

- REST API calls
- Interceptors for auth
- Error handling

### Local Storage

**sqflite**

- SQLite database
- Offline data persistence
- Query operations

**shared_preferences**

- Key-value storage
- Settings persistence
- User preferences

**flutter_secure_storage**

- Encrypted storage
- Token storage
- Credential storage

### UI Components

**flutter_markdown**

- Markdown rendering
- GitHub Flavored Markdown support

**flutter_html**

- HTML rendering
- Markdown to HTML conversion

**cached_network_image**

- Image caching
- Network image loading

**shimmer**

- Loading placeholders
- Skeleton screens

**flutter_staggered_grid_view**

- Masonry grid layout
- Pinterest-style grid

### Utilities

**timeago**

- Relative time formatting
- "2 hours ago" style

**intl**

- Internationalization
- Date/number formatting

**json_annotation / json_serializable**

- Model serialization
- fromJson/toJson generation

---

## Dependency Usage Examples

### Riverpod

```dart
// Provider definition
final myProvider = Provider<MyService>((ref) {
  return MyService();
});

// Widget usage
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(myProvider);
    ...
  }
}
```

### GoRouter

```dart
GoRouter(
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
    ),
  ],
  redirect: (context, state) {
    final loggedIn = // check auth
    if (!loggedIn) return '/login';
    return null;
  },
);
```

### Dio

```dart
final dio = Dio();
final response = await dio.get(
  '/api/v1/memos',
  options: Options(headers: {'Authorization': 'Bearer $token'}),
);
```

### SQLite

```dart
final db = await openDatabase('memos_note.db');
final results = await db.query('memos', where: 'synced = ?', whereArgs: [0]);
```

### Secure Storage

```dart
final storage = FlutterSecureStorage();
await storage.write(key: 'token', value: token);
final token = await storage.read(key: 'token');
```

### Connectivity Plus

```dart
final connectivityResult = await Connectivity().checkConnectivity();
if (connectivityResult.contains(ConnectivityResult.mobile) ||
    connectivityResult.contains(ConnectivityResult.wifi)) {
  // Online
}
```