import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:memos_note/core/constants/app_constants.dart';
import 'package:memos_note/core/utils/storage_service.dart';

// ── Sensitive-field redaction ─────────────────────────────────────────────────

/// Keys whose values should be masked in both request and response bodies.
const _bodySensitiveKeys = {
  'password',
  'accessToken',
  'content', // base64 attachment payloads — huge & uninteresting
};

/// Header keys whose values should be masked.
const _headerSensitiveKeys = {
  'authorization',
};

String _redactValue(String value) {
  if (value.length <= 4) return '****';
  return '${value.substring(0, 2)}...${value.substring(value.length - 2)}';
}

/// Recursively walk a JSON-like map / list and mask values for keys in
/// [_bodySensitiveKeys]. Returns a *new* object — the original is untouched.
dynamic _redactBody(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data.map((k, v) {
      if (_bodySensitiveKeys.contains(k) && v is String && v.isNotEmpty) {
        return MapEntry(k, _redactValue(v));
      }
      return MapEntry(k, _redactBody(v));
    });
  }
  if (data is List) {
    return data.map(_redactBody).toList();
  }
  return data;
}

/// Return a copy of [headers] with sensitive header values redacted.
Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
  return headers.map((k, v) {
    if (_headerSensitiveKeys.contains(k.toLowerCase()) && v is String) {
      return MapEntry(k, _redactValue(v));
    }
    return MapEntry(k, v);
  });
}

/// Max characters printed for a single log body.  Anything beyond this is
/// cut off with a "… (N chars truncated)" suffix so the debug console stays
/// readable on large responses (e.g. listMemos).
const _maxBodyChars = 1000;

String _prettyJson(dynamic data) {
  try {
    const encoder = JsonEncoder.withIndent('  ');
    final full = encoder.convert(data);
    if (full.length <= _maxBodyChars) return full;
    return '${full.substring(0, _maxBodyChars)}\n… (${full.length - _maxBodyChars} chars truncated)';
  } catch (_) {
    return data.toString();
  }
}

// ── Interceptors ──────────────────────────────────────────────────────────────

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Always sync baseUrl with the currently stored instance URL.
    // The repository's Dio may have been created before the user configured
    // their instance (e.g. on a fresh install), so the baseUrl could be
    // empty or stale.  Updating it here guarantees every request targets
    // the right host.
    final instanceUrl =
        StorageService.getString(AppConstants.memosInstanceKey);
    if (instanceUrl != null && instanceUrl.isNotEmpty) {
      options.baseUrl = instanceUrl;
    }

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
    if (!kDebugMode) {
      handler.next(options);
      return;
    }

    final uri = options.uri;
    final method = options.method;
    final headers = _redactHeaders(options.headers);

    final buf = StringBuffer()
      ..writeln('─── REQUEST ───────────────────────────────')
      ..writeln('$method $uri')
      ..writeln('Headers:');

    headers.forEach((k, v) {
      buf.writeln('  $k: $v');
    });

    if (options.data != null) {
      final redactedBody = _redactBody(options.data);
      buf.writeln('Body:');
      buf.writeln(_prettyJson(redactedBody));
    }

    if (options.queryParameters.isNotEmpty) {
      buf.writeln('Query:');
      options.queryParameters.forEach((k, v) {
        buf.writeln('  $k: $v');
      });
    }

    buf.writeln('───────────────────────────────────────────');
    debugPrint(buf.toString());

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!kDebugMode) {
      handler.next(response);
      return;
    }

    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method;
    final status = response.statusCode;

    final buf = StringBuffer()
      ..writeln('─── RESPONSE ───────────────────────────────')
      ..writeln('$method $uri → $status');

    if (response.headers.map.isNotEmpty) {
      buf.writeln('Headers:');
      response.headers.map.forEach((k, v) {
        buf.writeln('  $k: $v');
      });
    }

    if (response.data != null) {
      final redactedBody = _redactBody(response.data);
      buf.writeln('Body:');
      buf.writeln(_prettyJson(redactedBody));
    }

    buf.writeln('───────────────────────────────────────────');
    debugPrint(buf.toString());

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kDebugMode) {
      handler.next(err);
      return;
    }

    final uri = err.requestOptions.uri;
    final method = err.requestOptions.method;
    final status = err.response?.statusCode;

    final buf = StringBuffer()
      ..writeln('─── ERROR ─────────────────────────────────')
      ..writeln('$method $uri → $status')
      ..writeln('Type: ${err.type.name}')
      ..writeln('Message: ${err.message}');

    if (err.response?.data != null) {
      final redactedBody = _redactBody(err.response!.data);
      buf.writeln('Body:');
      buf.writeln(_prettyJson(redactedBody));
    }

    buf.writeln('───────────────────────────────────────────');
    debugPrint(buf.toString());

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