# Data Layer Documentation

## Models

### MemoModel

Primary data model for memos.

```dart
class MemoModel {
  final String name;        // "memos/{id}"
  final String uid;         // Unique ID
  final String content;     // Markdown content
  final String visibility;  // "PRIVATE" | "PROTECTED" | "PUBLIC"
  final bool pinned;
  final List<TagModel> tags;
  final List<AttachmentModel> attachments;
  final List<RelationModel> relations;
  final List<ReactionModel> reactions;
  final MemoPropertyModel properties;
  final DateTime createdTime;
  final DateTime? updatedTime;
  final String creator;
  final int? rowStatus;
}
```

### Related Models

| Model | Purpose |
|-------|---------|
| `TagModel` | Tag with name |
| `AttachmentModel` | File attachment (id, name, type, url) |
| `RelationModel` | Memo relationships (comment, reference) |
| `ReactionModel` | Emoji reactions |
| `MemoPropertyModel` | Metadata (hasTaskList, hasCode) |
| `ShareModel` | Share link with expiration |

### UserModel

User authentication and profile data.

```dart
class UserModel {
  final String name;
  final String id;
  final String? username;
  final String? nickname;
  final String? email;
  final String role;
  final String? avatarUrl;
}

class SignInRequest {
  final String username;
  final String password;
}

class SignInResponse {
  final UserModel user;
  final String accessToken;
}
```

### CommentModel

Comments on memos.

```dart
class CommentModel {
  final String name;
  final String parentMemoName;
  final String content;
  final String creator;
  final DateTime createdTime;
}
```

---

## Repositories

### MemosRepository

Main repository implementing offline-first architecture.

#### Authentication Methods

| Method | Description |
|--------|-------------|
| `signIn(username, password)` | Credential-based login |
| `signInWithToken(token)` | PAT/JWT token login |
| `signOut()` | Logout and clear all local data |
| `getCurrentUser()` | Get current user from cache or API |

#### Memo Operations

| Method | Offline Behavior |
|--------|-----------------|
| `listMemos()` | Returns local cache if offline |
| `createMemo(content)` | Creates locally first, queues sync |
| `updateMemo(name, content)` | Updates locally first, queues sync |
| `deleteMemo(name)` | Deletes locally first, queues sync |
| `syncAll()` | Fetches all from server, updates cache |

#### Attachment Operations

| Method | Offline Behavior |
|--------|-----------------|
| `uploadAttachment(file)` | Creates placeholder offline, uploads when online |
| `setMemoAttachments(memoId, attachments)` | Queues operation |

#### Comment Operations

| Method | Description |
|--------|-------------|
| `listComments(memoName)` | Get comments for memo |
| `createComment(memoName, content)` | Add comment |

#### Share Operations

| Method | Description |
|--------|-------------|
| `createMemoShare(memoName)` | Generate share link |
| `getMemoByShare(shareId)` | View public memo |
| `listMemoShares(memoName)` | List share links |
| `deleteMemoShare(shareId)` | Remove share |

---

## Remote API

### MemosApi

REST API client using Dio.

#### Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `signIn` | `POST /api/v1/auth/signin` | Password login |
| `signOut` | `POST /api/v1/auth/signout` | Logout |
| `getMe` | `GET /api/v1/auth/me` | Current user |
| `listMemos` | `GET /api/v1/memos` | List memos |
| `createMemo` | `POST /api/v1/memos` | Create memo |
| `updateMemo` | `PATCH /api/v1/memos/{id}` | Update memo |
| `deleteMemo` | `DELETE /api/v1/memos/{id}` | Delete memo |
| `listTags` | `GET /api/v1/memos:listTags` | Tag statistics |
| `uploadAttachment` | `POST /api/v1/attachments` | Upload file |
| `setAttachments` | `PATCH /api/v1/memos/{id}/attachments` | Link attachments |
| `listComments` | `GET /api/v1/{name}/comments` | Get comments |
| `createComment` | `POST /api/v1/{name}/comments` | Add comment |
| `createShare` | `POST /api/v1/memos/{id}/shares` | Create share |
| `getSharedMemo` | `GET /api/v1/memos/share/{id}` | View shared |

### Dio Interceptors

#### AuthInterceptor

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Adds Authorization: Bearer {token}
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // On 401, clear credentials and redirect to login
  }
}
```

---

## Local Database

### LocalDatabase

SQLite database setup using sqflite.

#### Tables

**memos**

| Column | Type | Description |
|--------|------|-------------|
| `id` | INTEGER | Primary key |
| `name` | TEXT | Unique "memos/{id}" |
| `content` | TEXT | Markdown content |
| `creator` | TEXT | Creator username |
| `created_time` | TEXT | ISO timestamp |
| `updated_time` | TEXT | ISO timestamp |
| `visibility` | TEXT | PRIVATE/PROTECTED/PUBLIC |
| `pinned` | INTEGER | 0 or 1 |
| `row_status` | INTEGER | Status flag |
| `tags_json` | TEXT | JSON array |
| `attachments_json` | TEXT | JSON array |
| `synced` | INTEGER | 0 or 1 |
| `local_updated` | TEXT | ISO timestamp |
| `is_local_only` | INTEGER | 0 or 1 |

**pending_ops**

| Column | Type | Description |
|--------|------|-------------|
| `id` | INTEGER | Primary key |
| `op_type` | TEXT | "create" | "update" | "delete" | "uploadAttachment" |
| `memo_id` | TEXT | Memo identifier |
| `payload` | TEXT | JSON operation data |
| `created_at` | TEXT | ISO timestamp |
| `retry_count` | INTEGER | Failed attempts |

#### Migrations

- v1 → v2: Added `attachments_json` column
- v2 → v3: Added `is_local_only` column

---

## DAOs

### MemoDao

CRUD operations for memos.

```dart
class MemoDao {
  Future<void> upsertMemo(MemoModel memo);
  Future<void> upsertMemos(List<MemoModel> memos);
  Future<List<MemoModel>> getAllMemos();
  Future<MemoModel?> getMemoById(String name);
  Future<List<MemoModel>> getLocalOnlyMemos();
  Future<void> replaceTempWithServer(String tempId, String serverId);
  Future<void> updateAttachments(String name, List<AttachmentModel> attachments);
  Future<void> deleteMemo(String name);
  Future<void> clearAll();
  Future<void> clearAllIncludingLocal();
}
```

### PendingOpsDao

Offline operation queue management.

```dart
enum PendingOpType { create, update, delete, uploadAttachment }

class PendingOp {
  final int? id;
  final PendingOpType opType;
  final String memoId;
  final String payload;
  final DateTime createdAt;
  final int retryCount;
}

class PendingOpsDao {
  Future<void> enqueue(PendingOp op);
  Future<List<PendingOp>> getAll();  // FIFO order
  Future<int> count();
  Future<void> delete(int id);
  Future<void> incrementRetry(int id);
  Future<List<PendingOp>> getByMemoId(String memoId);
  Future<void> deleteForMemo(String memoId);
  Future<void> updateMemoId(String oldId, String newId);
}
```

---

## Sync Service

### SyncService

Processes pending operations when online.

```dart
class SyncService {
  final MemosRepository _repo;

  Future<void> processPendingOps() async {
    final ops = await _repo.getPendingOps();
    for (final op in ops) {
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
        await _repo.deletePendingOp(op.id!);
      } catch (e) {
        if (op.retryCount >= 3) {
          await _repo.deletePendingOp(op.id!);
        } else {
          await _repo.incrementRetry(op.id!);
        }
      }
    }
  }
}
```

### Operation Handlers

| Handler | Process |
|---------|---------|
| `_handleCreate` | POST memo to server, replace temp ID in local DB |
| `_handleUpdate` | PATCH memo content |
| `_handleDelete` | DELETE memo from server |
| `_handleUploadAttachment` | Upload file, link to memo via PATCH |