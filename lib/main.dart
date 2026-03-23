import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/utils/storage_service.dart';
import 'core/providers/locale_provider.dart';
import 'data/local/db/local_database.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await LocalDatabase.database; // Initialize DB
  timeago.setLocaleMessages('en', timeago.EnMessages());
  timeago.setLocaleMessages('id', timeago.IdMessages());
  runApp(const ProviderScope(child: MemosApp()));
}

class MemosApp extends ConsumerStatefulWidget {
  const MemosApp({super.key});

  @override
  ConsumerState<MemosApp> createState() => _MemosAppState();
}

class _MemosAppState extends ConsumerState<MemosApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen((uri) {
      final router = ref.read(routerProvider);
      // Handle deep links: memos://app/memo/:id
      if (uri.host == 'app' || uri.host == 'memo') {
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          router.go('/memo/${Uri.encodeComponent('memos/${segments.last}')}');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'Memos',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
