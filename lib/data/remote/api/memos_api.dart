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
  Future<AttachmentModel> uploadAttachment(String filePath,
      {String? memoName}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      if (memoName != null) 'memo': memoName,
    });
    final res = await _dio.post(
      '/api/v1/attachments',
      data: formData,
    );
    return AttachmentModel.fromJson(
        res.data['attachment'] as Map<String, dynamic>);
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
