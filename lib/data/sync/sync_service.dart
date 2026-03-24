import 'package:connectivity_plus/connectivity_plus.dart';
import '../local/dao/memo_dao.dart';
import '../local/dao/pending_ops_dao.dart';
import '../models/memo_model.dart';
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
          case PendingOpType.uploadAttachment:
            await _handleUploadAttachment(op);
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

    final localId = op.memoId;

    // Snapshot local attachments (offline placeholders) before the temp row
    // is deleted by replaceTempWithServer, so they can be carried over to the
    // server row.
    List<AttachmentModel> localAttachments = [];
    if (localId != null) {
      final localMemo = await MemoDao.getMemoById(localId);
      localAttachments = localMemo?.attachments ?? [];
    }

    final serverMemo = await _api.createMemo({
      'content': content,
      'visibility': visibility,
    });

    if (localId != null) {
      await MemoDao.replaceTempWithServer(
        localId: localId,
        serverMemo: serverMemo,
      );

      // Re-apply any offline-added attachments (local placeholders) so that
      // subsequent uploadAttachment ops can still find and replace them.
      if (localAttachments.isNotEmpty) {
        await MemoDao.updateAttachments(serverMemo.id, localAttachments);
      }

      // Remap any pending upload-attachment ops that reference the old temp ID.
      await PendingOpsDao.updateMemoId(localId, serverMemo.id);
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

  /// Uploads a locally-queued attachment file to the server and links it to
  /// its memo, or links already-uploaded attachments if `action` is
  /// `'linkExisting'`.
  ///
  /// Re-reads the op from the DB before processing so that a preceding
  /// [_handleCreate] call in the same batch can update the memo ID from its
  /// temp value to the real server ID via [PendingOpsDao.updateMemoId].
  Future<void> _handleUploadAttachment(PendingOp op) async {
    // Re-read to pick up any memo_id update that happened in this same batch.
    final fresh =
        op.id != null ? (await PendingOpsDao.getById(op.id!) ?? op) : op;
    final memoId = fresh.memoId;

    if (memoId == null || memoId.startsWith('local_')) {
      // The create op for this memo has not been processed yet.
      // Throwing causes the sync loop to call incrementRetry so the op is
      // retried on the next processQueue call, by which time the create op
      // will have succeeded and PendingOpsDao.updateMemoId will have set the
      // real server ID.
      throw Exception('Memo create not yet synced for upload op ${op.id}');
    }

    // Handle linking of already-uploaded server attachments.
    if (fresh.payload['action'] == 'linkExisting') {
      final memoName = fresh.payload['memoName'] as String?;
      final names = (fresh.payload['attachmentNames'] as List?)
          ?.cast<String>();
      if (memoName != null && names != null && names.isNotEmpty) {
        await _api.setMemoAttachments(memoName, names);
      }
      return;
    }

    final filePath = fresh.payload['filePath'] as String?;
    final tempName = fresh.payload['tempAttachmentName'] as String?;
    if (filePath == null) return;

    // Ensure the memo still exists and still has the placeholder attachment
    // before uploading, to avoid creating orphaned attachments on the server.
    final memo = await MemoDao.getMemoById(memoId);
    if (memo == null) {
      // Memo was deleted or is otherwise unavailable; skip upload.
      return;
    }

    final attachments = memo.attachments ?? [];
    final hasPlaceholder =
        tempName != null && attachments.any((a) => a.name == tempName);
    if (!hasPlaceholder) {
      // The pending attachment placeholder no longer exists on this memo;
      // skip the upload so we don't create an orphaned server attachment.
      return;
    }

    final serverAttachment = await _api.uploadAttachment(filePath);

    final updatedAttachments = attachments.map((a) {
      return a.name == tempName ? serverAttachment : a;
    }).toList();

    await MemoDao.updateAttachments(memoId, updatedAttachments);

    final serverNames = updatedAttachments
        .where((a) => !a.name.startsWith('attachments/local_'))
        .map((a) => a.name)
        .toList();
    if (serverNames.isNotEmpty) {
      await _api.setMemoAttachments(memo.name, serverNames);
    }
  }
}
