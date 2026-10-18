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

  // interceptors
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await ref.read(tokenProvider).read();
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) async {
        // A 401 while signed in means the session expired: sign out so the
        // router sends the user back to Welcome. While signed out (wrong
        // password on login, or the check at app start) there is nothing to
        // sign out of, and Auth handles those cases itself.
        final status = error.response?.statusCode;
        if (status == 401 && ref.read(authProvider).value != null) {
          await ref.read(authProvider.notifier).logout();
        }
        handler.next(error);
      },
    ),
  );

  ref.onDispose(dio.close);
  return dio;
}

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  return ApiClient(ref.watch(dioProvider));
}
