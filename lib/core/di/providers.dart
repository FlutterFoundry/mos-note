import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/repositories/memos_repository.dart';
import '../../data/sync/sync_service.dart';
import '../../data/local/dao/pending_ops_dao.dart';
import '../../data/models/memo_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/comment_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/storage_service.dart';

// Repository provider
final memosRepositoryProvider = Provider<MemosRepository>((ref) {
  return MemosRepository();
});

// SyncService provider
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});

// ── Auth ─────────────────────────────────────────────────────────────────────

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
  (ref) => AuthNotifier(ref.watch(memosRepositoryProvider)),
);

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final MemosRepository _repo;

  AuthNotifier(this._repo) : super(const AsyncValue.loading()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final instanceUrl = StorageService.getString(AppConstants.memosInstanceKey);
    if (instanceUrl == null || instanceUrl.isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }
    final storedUsername = StorageService.getString(AppConstants.usernameKey);
    if (storedUsername != null && storedUsername.isNotEmpty) {
      try {
        final user = await _repo.getUserByUsername(storedUsername);
        state = AsyncValue.data(user);
        return;
      } catch (_) {}
    }
    state = const AsyncValue.data(null);
  }

  Future<void> signIn(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.signIn(username, password);
      state = AsyncValue.data(user);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> signInWithToken(String token) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.signInWithToken(token);
      state = AsyncValue.data(user);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> refresh() async {
    await _checkAuth();
  }
}

// ── Memos ─────────────────────────────────────────────────────────────────────

final memosProvider =
    StateNotifierProvider<MemosNotifier, AsyncValue<List<MemoModel>>>(
  (ref) => MemosNotifier(ref.watch(memosRepositoryProvider), ref),
);

class MemosNotifier extends StateNotifier<AsyncValue<List<MemoModel>>> {
  final MemosRepository _repo;
  final Ref _ref;

  MemosNotifier(this._repo, this._ref) : super(const AsyncValue.loading()) {
    loadMemos();
  }

  Future<void> loadMemos({bool refresh = false}) async {
    if (refresh) {
      state = const AsyncValue.loading();
    }
    try {
      final memos = await _repo.listMemos();
      state = AsyncValue.data(memos);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> createMemo(String content,
      {String visibility = 'PRIVATE'}) async {
    final memo = await _repo.createMemo(content, visibility: visibility);
    state.whenData((memos) {
      state = AsyncValue.data([memo, ...memos]);
    });
    // Refresh pending count after a create
    _ref.read(syncStatusProvider.notifier).refresh();
  }

  Future<void> updateMemo(String name, String content) async {
    final updated = await _repo.updateMemo(name, content);
    state.whenData((memos) {
      final idx = memos.indexWhere((m) => m.name == name);
      if (idx != -1) {
        final newList = List<MemoModel>.from(memos);
        newList[idx] = updated;
        state = AsyncValue.data(newList);
      }
    });
    _ref.read(syncStatusProvider.notifier).refresh();
  }

  Future<void> deleteMemo(String name) async {
    await _repo.deleteMemo(name);
    state.whenData((memos) {
      state = AsyncValue.data(memos.where((m) => m.name != name).toList());
    });
    _ref.read(syncStatusProvider.notifier).refresh();
  }

  /// Full server refresh + update local cache.
  Future<void> sync() async {
    _ref.read(syncStatusProvider.notifier).setSyncing(true);
    try {
      await _repo.syncAll();
      await loadMemos(refresh: true);
    } finally {
      _ref.read(syncStatusProvider.notifier).setSyncing(false);
    }
  }

  /// Flushes the pending-ops queue then refreshes the list.
  Future<int> processPendingOps() async {
    _ref.read(syncStatusProvider.notifier).setSyncing(true);
    try {
      final syncService = _ref.read(syncServiceProvider);
      final flushed = await syncService.processQueue();
      if (flushed > 0) {
        await loadMemos(refresh: true);
      }
      _ref.read(syncStatusProvider.notifier).refresh();
      return flushed;
    } finally {
      _ref.read(syncStatusProvider.notifier).setSyncing(false);
    }
  }
}

// ── Sync status ───────────────────────────────────────────────────────────────

class SyncStatus {
  final int pendingCount;
  final bool isSyncing;

  const SyncStatus({this.pendingCount = 0, this.isSyncing = false});

  SyncStatus copyWith({int? pendingCount, bool? isSyncing}) => SyncStatus(
        pendingCount: pendingCount ?? this.pendingCount,
        isSyncing: isSyncing ?? this.isSyncing,
      );
}

final syncStatusProvider =
    StateNotifierProvider<SyncStatusNotifier, SyncStatus>(
  (ref) => SyncStatusNotifier(),
);

class SyncStatusNotifier extends StateNotifier<SyncStatus> {
  SyncStatusNotifier() : super(const SyncStatus()) {
    refresh();
  }

  Future<void> refresh() async {
    final count = await PendingOpsDao.count();
    state = state.copyWith(pendingCount: count);
  }

  void setSyncing(bool value) {
    state = state.copyWith(isSyncing: value);
  }
}

// ── Connectivity ──────────────────────────────────────────────────────────────

/// Stream-based provider that emits true when the device has network access.
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) =>
      results.isNotEmpty && !results.contains(ConnectivityResult.none));
});

// ── Comments ──────────────────────────────────────────────────────────────────

final commentsProvider = StateNotifierProvider.family<CommentsNotifier,
    AsyncValue<List<CommentModel>>, String>(
  (ref, memoName) =>
      CommentsNotifier(ref.watch(memosRepositoryProvider), memoName),
);

class CommentsNotifier extends StateNotifier<AsyncValue<List<CommentModel>>> {
  final MemosRepository _repo;
  final String _memoName;

  CommentsNotifier(this._repo, this._memoName)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final comments = await _repo.listComments(_memoName);
      state = AsyncValue.data(comments);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> addComment(String content) async {
    final comment = await _repo.createComment(_memoName, content);
    state.whenData((comments) {
      state = AsyncValue.data([...comments, comment]);
    });
  }
}

// ── Tags ──────────────────────────────────────────────────────────────────────

final tagsProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.watch(memosRepositoryProvider).listTags();
});

// ── Single memo ───────────────────────────────────────────────────────────────

final memoDetailProvider =
    FutureProvider.family<MemoModel?, String>((ref, name) {
  return ref.watch(memosRepositoryProvider).getMemo(name);
});
