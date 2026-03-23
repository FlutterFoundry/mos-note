import 'package:dio/dio.dart';
import 'package:memos_note/core/constants/app_constants.dart';
import 'package:memos_note/core/utils/storage_service.dart';

class AuthInterceptor extends Interceptor {
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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      StorageService.remove(AppConstants.authTokenKey);
      StorageService.remove(AppConstants.accessTokenKey);
      StorageService.remove(AppConstants.userIdKey);
    }
    handler.next(err);
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
  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(LoggingInterceptor());
  return dio;
}
