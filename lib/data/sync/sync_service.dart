import 'package:connectivity_plus/connectivity_plus.dart';
import '../local/dao/memo_dao.dart';
import '../local/dao/pending_ops_dao.dart';
import '../remote/api/memos_api.dart';
import '../remote/interceptors/dio_interceptors.dart';

/// Maximum number of failed attempts before an op is abandoned.
const int _maxRetries = 3;

/// Processes the [pending_ops] queue and pushes each operation to the server.
///
/// - **create**: POST to server → replace local temp row → remove op
/// - **update**: PATCH to server → upsert server memo → remove op
/// - **delete**: DELETE on server → remove op
///
/// On failure the retry counter is incremented. Ops that have reached
/// [_maxRetries] are silently skipped (and should be garbage-collected
/// by the caller or a future cleanup pass).
class SyncService {
  late MemosApi _api;

  SyncService() {
    _api = MemosApi(createDio());
  }

  Future<bool> get _isOnline async {
    final result = await Connectivity().checkConnectivity();
    return result.isNotEmpty && !result.contains(ConnectivityResult.none);
  }

  /// Returns the number of unprocessed pending ops.
  Future<int> pendingCount() => PendingOpsDao.count();

  /// Processes all pending ops in FIFO order.
  /// Returns the number of ops successfully flushed.
  Future<int> processQueue() async {
    if (!await _isOnline) return 0;

    _api = MemosApi(createDio()); // refresh credentials
    final ops = await PendingOpsDao.getAll();
    int flushed = 0;

    for (final op in ops) {
      if (op.retryCount >= _maxRetries) continue; // give up on this op

      try {
        switch (op.opType) {
          case PendingOpType.create:
            await _handleCreate(op);
          case PendingOpType.update:
            await _handleUpdate(op);
          case PendingOpType.delete:
            await _handleDelete(op);
        }
        await PendingOpsDao.delete(op.id!);
        flushed++;
      } catch (_) {
        await PendingOpsDao.incrementRetry(op.id!);
      }
    }

    return flushed;
  }

  Future<void> _handleCreate(PendingOp op) async {
    final content = op.payload['content'] as String? ?? '';
    final visibility = op.payload['visibility'] as String? ?? 'PRIVATE';

    final serverMemo = await _api.createMemo({
      'content': content,
      'visibility': visibility,
    });

    final localId = op.memoId;
    if (localId != null) {
      await MemoDao.replaceTempWithServer(
        localId: localId,
        serverMemo: serverMemo,
      );
    }
  }

  Future<void> _handleUpdate(PendingOp op) async {
    final name = op.payload['name'] as String?;
    final content = op.payload['content'] as String? ?? '';

    if (name == null) return; // malformed op — skip

    // Skip if the memo is still local-only (create hasn't been synced yet)
    final id = name.split('/').last;
    if (id.startsWith('local_')) return;

    final serverMemo = await _api.updateMemo(
      name,
      {'content': content},
      updateMask: 'content',
    );
    await MemoDao.upsertMemo(serverMemo);
  }

  Future<void> _handleDelete(PendingOp op) async {
    final name = op.payload['name'] as String?;
    if (name == null) return;

    // If the memo was created while offline and never synced, there is nothing
    // to delete on the server — just drop the op.
    final id = name.split('/').last;
    if (id.startsWith('local_')) return;

    await _api.deleteMemo(name);
  }
}
