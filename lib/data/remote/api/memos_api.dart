import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:memos_note/data/models/memo_model.dart';
import 'package:memos_note/data/models/user_model.dart';
import 'package:memos_note/data/models/comment_model.dart';

class MemosApi {
  final Dio _dio;

  MemosApi(this._dio);

  // Auth
  Future<UserModel> signIn(Map<String, dynamic> body) async {
    final res = await _dio.post('/api/v1/auth/signin', data: body);
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> signOut() async {
    await _dio.post('/api/v1/auth/signout');
  }

  Future<UserModel> getAuthStatus() async {
    final res = await _dio.get('/api/v1/auth/status');
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  // Memos
  Future<ListMemosResponse> listMemos({
    int? pageSize,
    String? pageToken,
    String? filter,
  }) async {
    final res = await _dio.get('/api/v1/memos', queryParameters: {
      if (pageSize != null) 'pageSize': pageSize,
      if (pageToken != null) 'pageToken': pageToken,
      if (filter != null) 'filter': filter,
    });
    return ListMemosResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MemoModel> createMemo(Map<String, dynamic> body) async {
    final res = await _dio.post('/api/v1/memos', data: body);
    return MemoModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MemoModel> getMemo(String name) async {
    final res = await _dio.get('/api/v1/$name');
    return MemoModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MemoModel> updateMemo(
    String name,
    Map<String, dynamic> body, {
    String? updateMask,
  }) async {
    final res = await _dio.patch(
      '/api/v1/$name',
      data: body,
      queryParameters: {if (updateMask != null) 'updateMask': updateMask},
    );
    return MemoModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteMemo(String name) async {
    await _dio.delete('/api/v1/$name');
  }

  // Attachments
  Future<AttachmentModel> uploadAttachment(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final base64Content = base64Encode(bytes);
    final filename = filePath.split('/').last;

    // Determine MIME type from extension
    String mimeType = 'application/octet-stream';
    final ext = filename.toLowerCase().split('.').last;
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        mimeType = 'image/jpeg';
        break;
      case 'png':
        mimeType = 'image/png';
        break;
      case 'gif':
        mimeType = 'image/gif';
        break;
      case 'webp':
        mimeType = 'image/webp';
        break;
      case 'pdf':
        mimeType = 'application/pdf';
        break;
    }

    final res = await _dio.post(
      '/api/v1/attachments',
      data: {
        'filename': filename,
        'type': mimeType,
        'content': base64Content,
      },
    );
    return AttachmentModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> setMemoAttachments(
    String memoName,
    List<String> attachmentNames,
  ) async {
    final memoId = memoName.split('/').last;
    await _dio.patch(
      '/api/v1/memos/$memoId/attachments',
      data: {
        'name': memoName,
        'attachments': attachmentNames.map((name) => {'name': name}).toList(),
      },
    );
  }

  Future<List<AttachmentModel>> listMemoAttachments(String memoName) async {
    final memoId = memoName.split('/').last;
    final res = await _dio.get('/api/v1/memos/$memoId/attachments');
    final attachments = (res.data['attachments'] as List)
        .map((a) => AttachmentModel.fromJson(a as Map<String, dynamic>))
        .toList();
    return attachments;
  }

  // Comments
  Future<ListCommentsResponse> listComments(String name) async {
    final res = await _dio.get('/api/v1/$name/comments');
    return ListCommentsResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<CommentModel> createComment(
    String name,
    Map<String, dynamic> body,
  ) async {
    final res = await _dio.post('/api/v1/$name/comments', data: body);
    return CommentModel.fromJson(res.data as Map<String, dynamic>);
  }

  // User
  Future<UserModel> getUser(String name) async {
    final res = await _dio.get('/api/v1/$name');
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  /// Fetch user by bare username, e.g. "sheenazien8" → GET /api/v1/users/sheenazien8
  Future<UserModel> getUserByUsername(String username) async {
    final res = await _dio.get('/api/v1/users/$username');
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UserModel> updateUser(
    String name,
    Map<String, dynamic> body,
  ) async {
    final res = await _dio.patch('/api/v1/$name', data: body);
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  // Tags
  Future<Map<String, dynamic>> listTags() async {
    final res = await _dio.get('/api/v1/memos:listTags');
    return res.data as Map<String, dynamic>;
  }
}
