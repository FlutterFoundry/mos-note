# Presentation Layer Documentation

## Screens

### HomeScreen

Main memo list with masonry grid layout.

**Location**: `lib/presentation/screens/home/home_screen.dart`

#### Features

- Search bar with text filtering
- Tag filter chips
- Pull-to-refresh
- Offline banner with pending sync count
- Floating action button for new memo
- Profile avatar navigation
- Sync button with loading indicator

#### Key Widgets

**MemoCard**

```dart
Widget MemoCard(MemoModel memo, VoidCallback onTap) {
  // Displays:
  // - Content preview (truncated)
  // - Tags as chips
  // - Attachment indicator
  // - Relative timestamp
}
```

**_TagChip**

```dart
Widget _TagChip(String tag, bool selected, VoidCallback onTap) {
  // Filter chip for tag selection
}
```

#### State Usage

```dart
class HomeScreen extends ConsumerStatefulWidget { ... }

// In build:
final memos = ref.watch(memosProvider);
final syncCount = ref.watch(syncStatusProvider);
final tags = ref.watch(tagsProvider);
final connectivity = ref.watch(connectivityProvider);
```

---

### EditorScreen

Create and edit memos with markdown support.

**Location**: `lib/presentation/screens/editor/editor_screen.dart`

#### Features

- Visibility selector (Private/Protected/Public)
- Markdown toolbar (bold, italic, code, lists, quotes, links, tags, attachments)
- Slash command menu for formatting
- Image attachment with gallery picker
- Offline save support
- Attachment preview thumbnails

#### Markdown Toolbar

| Button | Action |
|--------|--------|
| **B** | `**bold**` |
| **I** | `*italic*` |
| **< >** | `` `code` `` |
| **•** | `- list item` |
| **>** | `> quote` |
| **link** | `[text](url)` |
| **#** | `#tag` |
| **image** | Image picker |

#### Key Widgets

**_SlashMenu**

Popup menu for markdown helpers, triggered by `/` key.

**_ToolbarButton**

Icon button with tooltip for formatting actions.

#### State Usage

```dart
class EditorScreen extends ConsumerStatefulWidget { ... }

// Memo creation/editing:
await ref.read(memosProvider.notifier).create(memo);
await ref.read(memosProvider.notifier).update(memo);
```

---

### MemoDetailScreen

View memo content with markdown rendering.

**Location**: `lib/presentation/screens/detail/memo_detail_screen.dart`

#### Features

- HTML rendering via `flutter_html` with markdown conversion
- Image attachments with full-screen viewer
- Share options (content + link or link only)
- Comments navigation
- Edit/Delete actions with confirmation dialog
- Pinned indicator, visibility badge

#### Actions

| Action | Description |
|--------|-------------|
| Edit | Navigate to `/editor/:name` |
| Delete | Confirm dialog, then delete |
| Share | Share sheet with memo content |
| Comments | Navigate to `/memo/:name/comments` |

#### State Usage

```dart
final memo = ref.watch(memoDetailProvider(name));
// Actions:
ref.read(memosProvider.notifier).delete(name);
```

---

### SharedMemoScreen

View publicly shared memos without authentication.

**Location**: `lib/presentation/screens/detail/shared_memo_screen.dart`

#### Features

- Markdown rendering
- Attachment display
- No auth required
- Deep link compatible

---

### LoginScreen

Authentication with credentials or PAT.

**Location**: `lib/presentation/screens/login/login_screen.dart`

#### Authentication Modes

| Mode | Fields |
|------|--------|
| Credentials | Username, Password |
| PAT | Personal Access Token |

#### Segmented Button

Switch between authentication modes.

#### State Usage

```dart
class LoginScreen extends ConsumerStatefulWidget { ... }

// Authentication:
if (mode == AuthMode.credentials) {
  await ref.read(authStateProvider.notifier).signIn(username, password);
} else {
  await ref.read(authStateProvider.notifier).signInWithToken(token);
}
```

---

### InstanceSetupScreen

Initial server connection configuration.

**Location**: `lib/presentation/screens/instance_setup/instance_setup_screen.dart`

#### Features

- Instance URL input
- URL normalization (https prefix, trailing slash removal)
- Connection validation
- Error display

#### URL Normalization

```dart
String normalizeUrl(String input) {
  var url = input.trim();
  if (!url.startsWith('http')) url = 'https://$url';
  if (url.endsWith('/')) url = url.substring(0, url.length - 1);
  return url;
}
```

---

### ProfileScreen

User profile and settings.

**Location**: `lib/presentation/screens/profile/profile_screen.dart`

#### Features

- Avatar, display name, email, role display
- Instance info
- Language selector (English/Indonesian)
- Change instance option
- Sign out with confirmation

#### State Usage

```dart
final user = ref.watch(authStateProvider).value;
final locale = ref.watch(localeProvider);
```

---

### CommentsScreen

View and add comments on memos.

**Location**: `lib/presentation/screens/comments/comments_screen.dart`

#### Features

- Comments list with user avatar and timestamp
- Text input for new comments
- Send button with loading indicator
- Empty state

#### State Usage

```dart
final comments = ref.watch(commentsProvider(memoName));

// Add comment:
await ref.read(commentsProvider(memoName).notifier).createComment(content);
```

---

## Routing

### GoRouter Configuration

```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/instance-setup',
        builder: (_, __) => InstanceSetupScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => HomeScreen(),
      ),
      GoRoute(
        path: '/memo/:name',
        builder: (_, state) => MemoDetailScreen(name: state.pathParameters['name']),
      ),
      GoRoute(
        path: '/editor',
        builder: (_, __) => EditorScreen(),
      ),
      GoRoute(
        path: '/editor/:name',
        builder: (_, state) => EditorScreen(name: state.pathParameters['name']),
      ),
      GoRoute(
        path: '/memo/:name/comments',
        builder: (_, state) => CommentsScreen(memoName: state.pathParameters['name']),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => ProfileScreen(),
      ),
      GoRoute(
        path: '/s/:shareId',
        builder: (_, state) => SharedMemoScreen(shareId: state.pathParameters['shareId']),
      ),
    ],
    redirect: (_, state) {
      // Auth and setup redirect logic
    },
  );
});
```

---

## UI Patterns

### Pull-to-Refresh

```dart
RefreshIndicator(
  onRefresh: () => ref.read(memosProvider.notifier).syncAll(),
  child: ListView(...),
)
```

### Offline Banner

```dart
if (connectivity == false) {
  return Banner(
    message: 'Offline - ${syncCount} pending',
    location: BannerLocation.top,
    child: content,
  );
}
```

### Loading States

```dart
ref.watch(provider).when(
  data: (data) => DataWidget(data),
  loading: () => LoadingWidget(),
  error: (err, stack) => ErrorWidget(err),
);
```

### AsyncValue Pattern

```dart
final asyncValue = ref.watch(someProvider);

return asyncValue.when(
  data: (data) => buildContent(data),
  loading: () => const CircularProgressIndicator(),
  error: (error, stack) => ErrorDisplay(error),
);
```