# Troubleshooting Guide

## Common Issues

### Authentication Issues

#### "Invalid credentials" error

**Symptoms:** Login fails with credentials error.

**Solutions:**
1. Verify username and password
2. Check instance URL is correct
3. Ensure instance is accessible
4. Try PAT (Personal Access Token) authentication

#### "Token expired" error

**Symptoms:** 401 errors after some time.

**Solutions:**
1. Token is automatically refreshed if possible
2. Sign out and sign in again
3. Check server session timeout settings

---

### Sync Issues

#### Memos not syncing

**Symptoms:** Created memos don't appear on other devices.

**Solutions:**
1. Check internet connectivity
2. Pull-to-refresh on home screen
3. Check pending operations count in offline banner
4. Verify server is accessible

#### Stuck pending operations

**Symptoms:** Sync keeps failing, operations not processed.

**Solutions:**
1. Clear app data and re-sync:
   ```dart
   // In development
   await repository.clearAllIncludingLocal();
   ```
2. Check server logs for errors
3. Verify API compatibility

#### Duplicate memos after sync

**Symptoms:** Local and server memos appear duplicated.

**Solutions:**
1. Pull-to-refresh to re-sync
2. Check if memo IDs are being correctly replaced
3. Verify `replaceTempWithServer()` is called

---

### Offline Issues

#### Can't create memos offline

**Symptoms:** Create fails when offline.

**Solutions:**
1. App should create local-only memos
2. Check `is_local_only` flag in database
3. Ensure pending ops queue is working

#### Offline banner shows wrong count

**Symptoms:** Pending count doesn't match actual operations.

**Solutions:**
1. Refresh sync status:
   ```dart
   ref.read(syncStatusProvider.notifier).refresh();
   ```
2. Check `pending_ops` table count

---

### UI Issues

#### Blank screen on startup

**Symptoms:** App shows white/black screen.

**Solutions:**
1. Check Flutter version: `flutter --version`
2. Run `flutter clean && flutter pub get`
3. Check for exceptions in debug console
4. Verify `instance_url` is set in SharedPreferences

#### Markdown not rendering

**Symptoms:** Content shows as raw markdown.

**Solutions:**
1. Check `flutter_markdown` dependency
2. Verify content encoding
3. Check for malformed markdown syntax

#### Images not loading

**Symptoms:** Attachment images show placeholder.

**Solutions:**
1. Check network connectivity
2. Verify image URLs are accessible
3. Clear image cache:
   ```dart
   await CachedNetworkImage.evictFromCache(url);
   ```

---

### Database Issues

#### Database migration error

**Symptoms:** App crashes on database open.

**Solutions:**
1. Check `onUpgrade` migration path
2. For development, delete app and reinstall
3. Ensure migrations are sequential (v1→v2→v3)

#### "Database locked" error

**Symptoms:** SQLite operations fail.

**Solutions:**
1. Close database properly:
   ```dart
   await database.close();
   ```
2. Use single database instance (singleton pattern)
3. Check for long-running transactions

---

### Network Issues

#### Connection timeout

**Symptoms:** API calls timeout.

**Solutions:**
1. Increase timeout:
   ```dart
   Dio(BaseOptions(connectTimeout: Duration(seconds: 60)))
   ```
2. Check server response time
3. Verify network stability

#### CORS error (Web)

**Symptoms:** API calls fail on web platform.

**Solutions:**
1. Server must have proper CORS headers
2. Use `--web-renderer html` if needed
3. Check server CORS configuration

---

### Build Issues

#### "Build failed" on Android

**Solutions:**
1. Check `android/app/build.gradle` configuration
2. Verify keystore configuration
3. Run `flutter clean`
4. Update Gradle: `cd android && ./gradlew wrapper --gradle-version=X.X`

#### iOS build issues

**Solutions:**
1. Run `cd ios && pod install`
2. Check minimum iOS version in `ios/Podfile`
3. Clean build folder in Xcode: `Product > Clean Build Folder`

#### Web build issues

**Solutions:**
1. Run `flutter clean`
2. Check `--web-renderer` option
3. Verify CORS settings for API

---

## Debug Tools

### Logging

Enable verbose logging:

```dart
// In development build
void main() {
  debugPrint = (message, {wrapWidth}) {
    developer.log(message, name: 'APP');
  };
  runApp(MyApp());
}
```

### Database Inspector

Query local database:

```dart
final db = await openDatabase('memos_note.db');
final result = await db.rawQuery('SELECT * FROM memos');
debugPrint(result.toString());
```

### Network Inspector

Log all HTTP requests:

```dart
dio.interceptors.add(
  LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
  ),
);
```

### Provider Debug

Check provider states:

```dart
// In ConsumerWidget
ref.listen<AsyncValue>(provider, (prev, next) {
  next.when(
    data: (d) => debugPrint('Data: $d'),
    loading: () => debugPrint('Loading...'),
    error: (e, s) => debugPrint('Error: $e'),
  );
});
```

---

## Performance Tips

### Reduce Rebuilds

Use `select` to minimize widget rebuilds:

```dart
final name = ref.watch(userProvider.select((u) => u.name));
```

### Lazy Loading

Load data on demand:

```dart
final posts = await ref.read(postsProvider.future);
```

### Database Indexing

Add indexes for frequently queried columns:

```sql
CREATE INDEX idx_memos_synced ON memos(synced);
CREATE INDEX idx_memos_creator ON memos(creator);
```

### Image Caching

Use `CachedNetworkImage` for remote images:

```dart
CachedNetworkImage(
  imageUrl: url,
  placeholder: (_, __) => CircularProgressIndicator(),
  errorWidget: (_, __, ___) => Icon(Icons.error),
);
```

---

## Getting Help

1. Check GitHub Issues for known problems
2. Enable verbose logging and capture stack traces
3. Provide Flutter doctor output: `flutter doctor -v`
4. Include device/platform information
5. Describe steps to reproduce