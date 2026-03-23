import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../db/local_database.dart';

enum PendingOpType { create, update, delete }

class PendingOp {
  final int? id;
  final PendingOpType opType;
  final String?
      memoId; // local temp ID for creates, server ID for update/delete
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;

  const PendingOp({
    this.id,
    required this.opType,
    this.memoId,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toRow() => {
        if (id != null) 'id': id,
        'op_type': opType.name,
        'memo_id': memoId,
        'payload': jsonEncode(payload),
        'created_at': createdAt.toIso8601String(),
        'retry_count': retryCount,
      };

  static PendingOp fromRow(Map<String, dynamic> row) => PendingOp(
        id: row['id'] as int?,
        opType: PendingOpType.values.byName(row['op_type'] as String),
        memoId: row['memo_id'] as String?,
        payload: jsonDecode(row['payload'] as String) as Map<String, dynamic>,
        createdAt: DateTime.parse(row['created_at'] as String),
        retryCount: (row['retry_count'] as int?) ?? 0,
      );
}

class PendingOpsDao {
  static Future<Database> get _db => LocalDatabase.database;

  static Future<int> enqueue(PendingOp op) async {
    final db = await _db;
    return db.insert('pending_ops', op.toRow());
  }

  static Future<List<PendingOp>> getAll() async {
    final db = await _db;
    final rows = await db.query('pending_ops', orderBy: 'created_at ASC');
    return rows.map(PendingOp.fromRow).toList();
  }

  static Future<int> count() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM pending_ops');
    return (result.first['c'] as int?) ?? 0;
  }

  static Future<void> delete(int id) async {
    final db = await _db;
    await db.delete('pending_ops', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> incrementRetry(int id) async {
    final db = await _db;
    await db.rawUpdate(
        'UPDATE pending_ops SET retry_count = retry_count + 1 WHERE id = ?',
        [id]);
  }

  /// Remove all ops for a given local/server memoId.
  static Future<void> deleteForMemo(String memoId) async {
    final db = await _db;
    await db.delete('pending_ops', where: 'memo_id = ?', whereArgs: [memoId]);
  }

  static Future<void> clearAll() async {
    final db = await _db;
    await db.delete('pending_ops');
  }
}
