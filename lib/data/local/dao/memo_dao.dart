import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../db/local_database.dart';
import '../../models/memo_model.dart';

class MemoDao {
  static Future<Database> get _db => LocalDatabase.database;

  /// Insert or replace a memo. Pass [isLocalOnly] = true when saving offline.
  static Future<void> upsertMemo(MemoModel memo,
      {bool isLocalOnly = false}) async {
    final db = await _db;
    await db.insert(
      'memos',
      {
        'id': memo.id,
        'name': memo.name,
        'content': memo.content,
        'creator': memo.creator,
        'create_time': memo.createTime,
        'update_time': memo.updateTime,
        'display_time': memo.displayTime,
        'visibility': memo.visibility,
        'pinned': (memo.pinned ?? false) ? 1 : 0,
        'row_status': memo.rowStatus,
        'tags_json':
            jsonEncode(memo.tags?.map((t) => t.toJson()).toList() ?? []),
        'attachments_json':
            jsonEncode(memo.attachments?.map((a) => a.toJson()).toList() ?? []),
        'synced': isLocalOnly ? 0 : 1,
        'local_updated': 0,
        'is_local_only': isLocalOnly ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> upsertMemos(List<MemoModel> memos) async {
    final db = await _db;
    final batch = db.batch();
    for (final memo in memos) {
      batch.insert(
        'memos',
        {
          'id': memo.id,
          'name': memo.name,
          'content': memo.content,
          'creator': memo.creator,
          'create_time': memo.createTime,
          'update_time': memo.updateTime,
          'display_time': memo.displayTime,
          'visibility': memo.visibility,
          'pinned': (memo.pinned ?? false) ? 1 : 0,
          'row_status': memo.rowStatus,
          'tags_json':
              jsonEncode(memo.tags?.map((t) => t.toJson()).toList() ?? []),
          'attachments_json': jsonEncode(
              memo.attachments?.map((a) => a.toJson()).toList() ?? []),
          'synced': 1,
          'local_updated': 0,
          'is_local_only': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<List<MemoModel>> getAllMemos() async {
    final db = await _db;
    final rows = await db.query(
      'memos',
      where: "row_status != 'ARCHIVED' OR row_status IS NULL",
      orderBy: 'display_time DESC',
    );
    return rows.map(_rowToMemo).toList();
  }

  static Future<MemoModel?> getMemoById(String id) async {
    final db = await _db;
    final rows = await db.query('memos', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _rowToMemo(rows.first);
  }

  /// Returns memos that were created offline and haven't been synced yet.
  static Future<List<MemoModel>> getLocalOnlyMemos() async {
    final db = await _db;
    final rows = await db.query(
      'memos',
      where: 'is_local_only = 1',
      orderBy: 'display_time DESC',
    );
    return rows.map(_rowToMemo).toList();
  }

  /// After a successful server create, swap the temp local ID/name for the
  /// real server values and clear the is_local_only flag.
  static Future<void> replaceTempWithServer({
    required String localId,
    required MemoModel serverMemo,
  }) async {
    final db = await _db;
    // Delete the temp row
    await db.delete('memos', where: 'id = ?', whereArgs: [localId]);
    // Insert the canonical server row
    await upsertMemo(serverMemo, isLocalOnly: false);
  }

  /// Updates only the `attachments_json` column for a memo, preserving all
  /// other fields (including the `is_local_only` flag).
  static Future<void> updateAttachments(
    String memoId,
    List<AttachmentModel> attachments,
  ) async {
    final db = await _db;
    await db.update(
      'memos',
      {
        'attachments_json':
            jsonEncode(attachments.map((a) => a.toJson()).toList()),
      },
      where: 'id = ?',
      whereArgs: [memoId],
    );
  }

  static Future<void> deleteMemo(String id) async {
    final db = await _db;
    await db.delete('memos', where: 'id = ?', whereArgs: [id]);
  }

  /// Clears only synced memos (preserves local-only rows so they are not lost
  /// during a full-refresh sync while there are pending offline writes).
  static Future<void> clearAll() async {
    final db = await _db;
    await db.delete('memos', where: 'is_local_only = 0');
  }

  /// Wipes every row including offline-only memos. Used on sign-out.
  static Future<void> clearAllIncludingLocal() async {
    final db = await _db;
    await db.delete('memos');
  }

  static MemoModel _rowToMemo(Map<String, dynamic> row) {
    final tagsJson = row['tags_json'] as String?;
    final attachmentsJson = row['attachments_json'] as String?;
    final tags = tagsJson != null && tagsJson.isNotEmpty
        ? (jsonDecode(tagsJson) as List)
            .map((t) => TagModel.fromJson(t as Map<String, dynamic>))
            .toList()
        : <TagModel>[];
    final attachments = attachmentsJson != null && attachmentsJson.isNotEmpty
        ? (jsonDecode(attachmentsJson) as List)
            .map((a) => AttachmentModel.fromJson(a as Map<String, dynamic>))
            .toList()
        : <AttachmentModel>[];

    return MemoModel(
      name: row['name'] as String,
      content: row['content'] as String,
      creator: row['creator'] as String?,
      createTime: row['create_time'] as String?,
      updateTime: row['update_time'] as String?,
      displayTime: row['display_time'] as String?,
      visibility: row['visibility'] as String?,
      pinned: (row['pinned'] as int?) == 1,
      rowStatus: row['row_status'] as String?,
      tags: tags,
      attachments: attachments,
    );
  }
}
