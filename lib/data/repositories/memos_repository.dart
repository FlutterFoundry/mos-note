import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/storage_service.dart';
import '../../core/utils/jwt_utils.dart';
import '../local/dao/memo_dao.dart';
import '../local/dao/pending_ops_dao.dart';
import '../models/memo_model.dart';
import '../models/user_model.dart';
import '../models/comment_model.dart';
import '../remote/api/memos_api.dart';
import '../remote/interceptors/dio_interceptors.dart';

class MemosRepository {
  late MemosApi _api;

  MemosRepository() {
    _api = MemosApi(createDio());
  }

  void refreshApi() {
    _api = MemosApi(createDio());
  }

  Future<bool> get _isOnline async {
    final result = await Connectivity().checkConnectivity();
    return result.isNotEmpty && !result.contains(ConnectivityResult.none);
  }

  // ── Auth ─────────────────────────────────────────────────────────────────

  Future<UserModel> signIn(String username, String password) async {
    try {
      final user = await _api.signIn({
        'username': username,
        'password': password,
      });
      await StorageService.setString(AppConstants.userIdKey, user.userId);
      await StorageService.setString(AppConstants.usernameKey, user.username);
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception(
          'This Memos instance does not support password sign-in via the REST API. '
          'Please use a Personal Access Token instead.',
        );
      }
      rethrow;
    }
  }

  /// Sign in using a Personal Access Token (PAT).
  Future<UserModel> signInWithToken(String token) async {
    final payload = decodeJwtPayload(token);
    if (payload == null) {
      throw Exception('Malformed access token.');
    }
    final username = payload['name'] as String?;
    if (username == null || username.isEmpty) {
      throw Exception('Token does not contain a username claim.');
    }

    await StorageService.setString(AppConstants.accessTokenKey, token);
    await StorageService.remove(AppConstants.authTokenKey);
    refreshApi();

    try {
      final user = await _api.getUserByUsername(username);
      await StorageService.setString(AppConstants.userIdKey, user.userId);
      await StorageService.setString(AppConstants.usernameKey, user.username);
      return user;
    } catch (e) {
      await StorageService.remove(AppConstants.accessTokenKey);
      rethrow;
    }
  }

  Future<UserModel?> getAuthStatus() async {
    try {
      return await _api.getAuthStatus();
    } on DioException {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _api.signOut();
    } catch (_) {}
    await StorageService.remove(AppConstants.authTokenKey);
    await StorageService.remove(AppConstants.accessTokenKey);
    await StorageService.remove(AppConstants.userIdKey);
    await StorageService.remove(AppConstants.usernameKey);
    // Wipe all local data including offline-only memos on sign-out
    await MemoDao.clearAllIncludingLocal();
    await PendingOpsDao.clearAll();
  }

  // ── Memos ─────────────────────────────────────────────────────────────────

  Future<List<MemoModel>> listMemos({
    int pageSize = AppConstants.pageSize,
    String? pageToken,
    String? filter,
  }) async {
    final online = await _isOnline;
    if (online) {
      try {
        final response = await _api.listMemos(
          pageSize: pageSize,
          pageToken: pageToken,
          filter: filter,
        );
        if (pageToken == null) {
          // First page — replace synced cache while preserving local-only rows
          await MemoDao.clearAll();
          await MemoDao.upsertMemos(response.memos);
        }
        // Merge server list with any pending local-only memos so they are
        // always visible in the UI.
        final localOnly = await MemoDao.getLocalOnlyMemos();
        final serverIds = response.memos.map((m) => m.id).toSet();
        final merged = [
          ...localOnly.where((m) => !serverIds.contains(m.id)),
          ...response.memos,
        ];
        return merged;
      } on DioException {
        return MemoDao.getAllMemos();
      }
    } else {
      return MemoDao.getAllMemos();
    }
  }

  /// Local-first create: saves to SQLite immediately, queues a pending op,
  /// then attempts to push to server. On failure the op stays queued.
  Future<MemoModel> createMemo(String content,
      {String visibility = 'PRIVATE'}) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final tempId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final tempName = 'memos/$tempId';

    final localMemo = MemoModel(
      name: tempName,
      content: content,
      visibility: visibility,
      createTime: now,
      updateTime: now,
      displayTime: now,
      rowStatus: 'NORMAL',
    );

    // 1. Save locally first (optimistic)
    await MemoDao.upsertMemo(localMemo, isLocalOnly: true);

    // 2. Queue the pending operation
    final opId = await PendingOpsDao.enqueue(PendingOp(
      opType: PendingOpType.create,
      memoId: tempId,
      payload: {'content': content, 'visibility': visibility},
      createdAt: DateTime.now(),
    ));

    final online = await _isOnline;
    if (online) {
      try {
        final serverMemo = await _api.createMemo({
          'content': content,
          'visibility': visibility,
        });
        // Replace temp row with the real server memo
        await MemoDao.replaceTempWithServer(
          localId: tempId,
          serverMemo: serverMemo,
        );
        // Op succeeded — remove it from the queue
        await PendingOpsDao.delete(opId);
        return serverMemo;
      } catch (_) {
        // Leave in queue; return the local version so the UI stays responsive
      }
    }

    return localMemo;
  }

  Future<MemoModel?> getMemo(String name) async {
    final online = await _isOnline;
    if (online) {
      try {
        final memo = await _api.getMemo(name);
        await MemoDao.upsertMemo(memo);
        return memo;
      } on DioException {
        final id = name.split('/').last;
        return MemoDao.getMemoById(id);
      }
    } else {
      final id = name.split('/').last;
      return MemoDao.getMemoById(id);
    }
  }

  /// Local-first update: patches SQLite immediately, queues a pending op,
  /// then attempts to push to server.
  Future<MemoModel> updateMemo(String name, String content) async {
    final id = name.split('/').last;
    final existing = await MemoDao.getMemoById(id);

    // Optimistic local update
    if (existing != null) {
      final updated = MemoModel(
        name: existing.name,
        uid: existing.uid,
        content: content,
        creator: existing.creator,
        createTime: existing.createTime,
        updateTime: DateTime.now().toUtc().toIso8601String(),
        displayTime: existing.displayTime,
        visibility: existing.visibility,
        pinned: existing.pinned,
        rowStatus: existing.rowStatus,
        tags: existing.tags,
        attachments: existing.attachments,
      );
      await MemoDao.upsertMemo(updated);
    }

    // Queue the pending op
    final opId = await PendingOpsDao.enqueue(PendingOp(
      opType: PendingOpType.update,
      memoId: id,
      payload: {'name': name, 'content': content},
      createdAt: DateTime.now(),
    ));

    final online = await _isOnline;
    if (online) {
      try {
        final serverMemo = await _api.updateMemo(
          name,
          {'content': content},
          updateMask: 'content',
        );
        await MemoDao.upsertMemo(serverMemo);
        await PendingOpsDao.delete(opId);
        return serverMemo;
      } catch (_) {
        // Leave in queue; return the optimistic local version
      }
    }

    // Return the locally-patched version
    return (await MemoDao.getMemoById(id)) ??
        MemoModel(name: name, content: content);
  }

  // ── Attachments ────────────────────────────────────────────────────────

  // ── Attachments ────────────────────────────────────────────────────────

  Future<AttachmentModel> uploadAttachment(String filePath) async {
    return _api.uploadAttachment(filePath);
  }

  Future<void> setMemoAttachments(
      String memoName, List<String> attachmentNames) async {
    return _api.setMemoAttachments(memoName, attachmentNames);
  }

  Future<List<AttachmentModel>> listMemoAttachments(String memoName) async {
    return _api.listMemoAttachments(memoName);
  }

  /// Local-first delete: removes from SQLite immediately, queues a pending op,
  /// then attempts to push to server.
  Future<void> deleteMemo(String name) async {
    final id = name.split('/').last;

    // Remove locally right away
    await MemoDao.deleteMemo(id);
    // Also remove any pending ops for this memo (e.g. a pending create)
    await PendingOpsDao.deleteForMemo(id);

    final online = await _isOnline;
    if (online) {
      try {
        await _api.deleteMemo(name);
        return; // success — no need to queue
      } catch (_) {
        // Fall through to queue
      }
    }

    // Queue the delete for later
    await PendingOpsDao.enqueue(PendingOp(
      opType: PendingOpType.delete,
      memoId: id,
      payload: {'name': name},
      createdAt: DateTime.now(),
    ));
  }

  // ── Comments ──────────────────────────────────────────────────────────────

  Future<List<CommentModel>> listComments(String memoName) async {
    final response = await _api.listComments(memoName);
    return response.memos;
  }

  Future<CommentModel> createComment(String memoName, String content) async {
    return _api.createComment(memoName, {'content': content});
  }

  // ── User ──────────────────────────────────────────────────────────────────

  Future<UserModel> getUser(String name) async {
    return _api.getUser(name);
  }

  Future<UserModel> getUserByUsername(String username) async {
    return _api.getUserByUsername(username);
  }

  Future<UserModel> updateUser(String name, Map<String, dynamic> data) async {
    return _api.updateUser(name, data);
  }

  // ── Tags ──────────────────────────────────────────────────────────────────

  Future<Map<String, int>> listTags() async {
    final response = await _api.listTags();
    final tagAmounts = response['tagAmounts'] as Map<String, dynamic>?;
    if (tagAmounts == null) return {};
    return tagAmounts.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  // ── Sync ──────────────────────────────────────────────────────────────────

  /// Full refresh: re-fetches all memos from the server (preserves local-only
  /// rows), then returns the merged list.
  Future<void> syncAll() async {
    final online = await _isOnline;
    if (!online) return;
    try {
      final response = await _api.listMemos(pageSize: 100);
      await MemoDao.clearAll(); // preserves is_local_only rows
      await MemoDao.upsertMemos(response.memos);
    } catch (_) {}
  }
}
