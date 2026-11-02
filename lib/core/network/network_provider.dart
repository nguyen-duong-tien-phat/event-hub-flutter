import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:event_hub_mobile/core/config/env.dart';
import 'package:event_hub_mobile/core/network/api_client.dart';
import 'package:event_hub_mobile/core/network/token_storage.dart';
import 'package:event_hub_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_provider.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // A second Dio without our interceptor: used to refresh the session and to
  // repeat the request that failed. Going through the interceptor again would
  // wait for the very refresh it is part of.
  final plain = Dio(dio.options.copyWith())
    ..httpClientAdapter = _SameAdapter(dio);
  dio.interceptors.add(_AuthInterceptor(ref, plain));

  ref.onDispose(dio.close);
  return dio;
}

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  return ApiClient(ref.watch(dioProvider));
}

/// Adds the access token to requests. When the server answers 401 (the access
/// token ran out) it trades the refresh token for a new pair and repeats the
/// request, so the user stays signed in. Only when the refresh token is
/// refused too is the user signed out.
///
/// Queued: when several requests fail at once they are handled one after
/// another. The first refreshes; the others find the token already renewed
/// and just repeat their request. The refresh token works once, so refreshing
/// twice with it would look like a stolen token and end the session.
class _AuthInterceptor extends QueuedInterceptor {
  _AuthInterceptor(this._ref, this._plain);

  final Ref _ref;
  final Dio _plain;

  static const _authPaths = ['/auth/login', '/auth/refresh', '/auth/logout'];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _ref.read(tokenProvider).read();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final request = error.requestOptions;
    if (error.response?.statusCode != 401 ||
        _authPaths.contains(request.path)) {
      return handler.next(error);
    }

    final storage = _ref.read(tokenProvider);
    try {
      final current = await storage.read();
      // Another request may have renewed the token while this one was failing.
      var access =
          current != null &&
              request.headers['Authorization'] != 'Bearer $current'
          ? current
          : await _refresh(storage);

      if (access == null) {
        await _signOut(storage);
        return handler.next(error);
      }

      request.headers['Authorization'] = 'Bearer $access';
      handler.resolve(await _plain.fetch(request));
    } on DioException catch (e) {
      // Offline, or the repeated request itself failed: not a reason to sign out.
      handler.next(e);
    }
  }

  /// A new access token, or null when the refresh token is gone or refused.
  /// Other failures (no network) are thrown, so the user stays signed in.
  Future<String?> _refresh(TokenStorage storage) async {
    final refreshToken = await storage.readRefresh();
    if (refreshToken == null) return null;

    try {
      final response = await _plain.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final body = response.data!;
      await storage.save(
        body['token'] as String,
        body['refreshToken'] as String,
      );
      return body['token'] as String;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      rethrow;
    }
  }

  Future<void> _signOut(TokenStorage storage) async {
    // While signed out (the check at app start) Auth clears things itself.
    if (_ref.read(authProvider).value != null) {
      await _ref.read(authProvider.notifier).sessionEnded();
    } else {
      await storage.clear();
    }
  }
}

/// Sends through whatever adapter [_dio] has, so both Dios share one transport.
class _SameAdapter implements HttpClientAdapter {
  _SameAdapter(this._dio);

  final Dio _dio;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => _dio.httpClientAdapter.fetch(options, requestStream, cancelFuture);

  @override
  void close({bool force = false}) {}
}
