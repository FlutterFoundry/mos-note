import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../di/providers.dart';
import '../constants/app_constants.dart';
import '../utils/storage_service.dart';
import '../../data/models/memo_model.dart';
import '../../presentation/screens/instance_setup/instance_setup_screen.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/editor/editor_screen.dart';
import '../../presentation/screens/detail/memo_detail_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/comments/comments_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/instance-setup',
    redirect: (context, state) {
      final instanceUrl =
          StorageService.getString(AppConstants.memosInstanceKey);
      final hasInstance = instanceUrl != null && instanceUrl.isNotEmpty;
      final isSettingUp = state.matchedLocation == '/instance-setup';

      if (!hasInstance && !isSettingUp) return '/instance-setup';
      if (hasInstance && isSettingUp) {
        return authState.when(
          data: (user) => user != null ? '/home' : '/login',
          loading: () => null,
          error: (_, __) => '/login',
        );
      }

      return authState.when(
        data: (user) {
          if (user == null &&
              state.matchedLocation != '/login' &&
              state.matchedLocation != '/instance-setup') {
            return '/login';
          }
          if (user != null && state.matchedLocation == '/login') {
            return '/home';
          }
          return null;
        },
        loading: () => null,
        error: (_, __) => '/login',
      );
    },
    routes: [
      GoRoute(
        path: '/instance-setup',
        name: 'instance-setup',
        builder: (context, state) => const InstanceSetupScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/memo/:name',
        name: 'memo-detail',
        builder: (context, state) {
          final name = state.pathParameters['name']!;
          return MemoDetailScreen(memoName: Uri.decodeComponent(name));
        },
      ),
      GoRoute(
        path: '/editor',
        name: 'editor-new',
        builder: (context, state) => const EditorScreen(),
      ),
      GoRoute(
        path: '/editor/:name',
        name: 'editor-edit',
        builder: (context, state) {
          final name = state.pathParameters['name']!;
          final extra = state.extra as Map<String, dynamic>?;
          return EditorScreen(
            memoName: Uri.decodeComponent(name),
            initialContent: extra?['content'] as String?,
            initialAttachments: extra?['attachments'] as List<AttachmentModel>?,
          );
        },
      ),
      GoRoute(
        path: '/memo/:name/comments',
        name: 'comments',
        builder: (context, state) {
          final name = state.pathParameters['name']!;
          return CommentsScreen(memoName: Uri.decodeComponent(name));
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
