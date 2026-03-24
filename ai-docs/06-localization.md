# Localization Documentation

## Supported Languages

| Language | Code |
|----------|------|
| English | `en` |
| Indonesian | `id` |

## File Structure

```
lib/l10n/
├── app_localizations.dart         # Generated base class
├── app_localizations_en.dart      # English implementation
├── app_localizations_id.dart      # Indonesian implementation
├── app_en.arb                     # English source
└── app_id.arb                     # Indonesian source
```

## ARB Format

Translation files use ARB (Application Resource Bundle) format.

**Example (app_en.arb):**

```json
{
  "@@locale": "en",
  "appTitle": "Memos Note",
  "loginButton": "Sign In",
  "logoutButton": "Sign Out",
  "createMemo": "Create Memo",
  "editMemo": "Edit Memo",
  "deleteMemo": "Delete Memo",
  "deleteConfirm": "Are you sure you want to delete this memo?",
  "cancel": "Cancel",
  "confirm": "Confirm",
  "save": "Save",
  "share": "Share",
  "comments": "Comments",
  "addComment": "Add Comment",
  "noMemos": "No memos yet",
  "offline": "Offline",
  "syncing": "Syncing...",
  "pendingOps": "{count, plural, =1{1 pending operation} other{{count} pending operations}}"
}
```

## Accessing Translations

### In Widgets

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Text(AppLocalizations.of(context)!.createMemo)
```

### With Provider

```dart
final locale = ref.watch(localeProvider);
final localizations = AppLocalizations.of(context);
```

## Locale Provider

```dart
class LocaleNotifier extends StateNotifier<Locale?> {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('id'),
  ];

  Future<void> setLocale(Locale locale) async {
    await _storage.setString('locale', locale.languageCode);
    state = locale;
  }

  Locale? getLocale() {
    return state;
  }
}
```

## Supported Locales Configuration

**l10n.yaml:**

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

**pubspec.yaml:**

```yaml
flutter:
  generate: true
```

## Adding a New Language

1. Add language code to supported locales:

```dart
// locale_provider.dart
static const List<Locale> supportedLocales = [
  Locale('en'),
  Locale('id'),
  Locale('fr'), // Add French
];
```

2. Create ARB file:

**lib/l10n/app_fr.arb:**

```json
{
  "@@locale": "fr",
  "appTitle": "Memos Note",
  "loginButton": "Se connecter",
  "logoutButton": "Se déconnecter",
  "createMemo": "Créer un mémo",
  ...
}
```

3. Run code generation:

```bash
flutter gen-l10n
```

## Key Translations

| Key | English | Indonesian |
|-----|---------|------------|
| `appTitle` | Memos Note | Memos Note |
| `loginButton` | Sign In | Masuk |
| `logoutButton` | Sign Out | Keluar |
| `createMemo` | Create Memo | Buat Memo |
| `editMemo` | Edit Memo | Edit Memo |
| `deleteMemo` | Delete Memo | Hapus Memo |
| `deleteConfirm` | Are you sure...? | Apa Anda yakin...? |
| `cancel` | Cancel | Batal |
| `confirm` | Confirm | Konfirmasi |
| `save` | Save | Simpan |
| `share` | Share | Bagikan |
| `comments` | Comments | Komentar |
| `addComment` | Add Comment | Tambah Komentar |
| `noMemos` | No memos yet | Belum ada memo |
| `offline` | Offline | Offline |
| `syncing` | Syncing... | Menyinkronkan... |
| `profile` | Profile | Profil |
| `settings` | Settings | Pengaturan |
| `language` | Language | Bahasa |
| `instanceSetup` | Connect to Server | Hubungkan ke Server |
| `instanceUrl` | Server URL | URL Server |
| `connect` | Connect | Hubungkan |