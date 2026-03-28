import 'package:dio/dio.dart';
import 'package:memos_note/core/constants/app_constants.dart';
import 'package:memos_note/core/utils/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  bool _isRefreshing = false;

  AuthInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Personal Access Token takes precedence over session token
    final pat = StorageService.getString(AppConstants.accessTokenKey);
    final sessionToken = StorageService.getString(AppConstants.authTokenKey);
    final token = (pat != null && pat.isNotEmpty) ? pat : sessionToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try to refresh the token once if we haven't already
      if (!_isRefreshing && err.requestOptions.path != '/api/v1/auth/token') {
        _isRefreshing = true;
        try {
          final userId = StorageService.getString(AppConstants.userIdKey);
          if (userId != null && userId.isNotEmpty) {
            final refreshed = await _refreshToken(userId);
            if (refreshed) {
              _isRefreshing = false;
              // Retry the original request with new token
              final retryResponse = await _retry(err.requestOptions);
              return handler.resolve(retryResponse);
            }
          }
        } catch (_) {}
        _isRefreshing = false;
      }

      // Clear tokens if refresh failed
      StorageService.remove(AppConstants.authTokenKey);
      StorageService.remove(AppConstants.accessTokenKey);
      StorageService.remove(AppConstants.accessTokenExpiryKey);
    }
    handler.next(err);
  }

  Future<bool> _refreshToken(String userId) async {
    try {
      final instanceUrl =
          StorageService.getString(AppConstants.memosInstanceKey) ?? '';
      final refreshDio = Dio(BaseOptions(baseUrl: instanceUrl));
      final response = await refreshDio.post('/api/v1/auth/token', data: {
        'type': 'ACCESS_TOKEN',
        'name': 'users/$userId',
      });

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final accessToken = data['accessToken'] as String?;
        final expiresAt = data['accessTokenExpiresAt'] as String?;

        if (accessToken != null) {
          await StorageService.setString(
              AppConstants.accessTokenKey, accessToken);
          if (expiresAt != null) {
            await StorageService.setString(
                AppConstants.accessTokenExpiryKey, expiresAt);
          }
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = StorageService.getString(AppConstants.accessTokenKey);
    if (token != null && token.isNotEmpty) {
      requestOptions.headers['Authorization'] = 'Bearer $token';
    }
    return dio.fetch(requestOptions);
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // In debug mode we'd log here
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}

Dio createDio() {
  final instanceUrl =
      StorageService.getString(AppConstants.memosInstanceKey) ?? '';
  final dio = Dio(
    BaseOptions(
      baseUrl: instanceUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(AuthInterceptor(dio));
  dio.interceptors.add(LoggingInterceptor());
  return dio;
}
