import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:event_hub_mobile/core/network/network_provider.dart';
import 'package:event_hub_mobile/core/network/token_storage.dart';
import 'package:event_hub_mobile/features/auth/data/models/user.dart';
import 'package:event_hub_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryStorage extends TokenStorage {
  String? access;
  String? refresh;

  @override
  Future<String?> read() async => access;

  @override
  Future<String?> readRefresh() async => refresh;

  @override
  Future<void> save(String accessToken, String refreshToken) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

class _SignedOut extends Auth {
  @override
  Future<User?> build() async => null;
}

/// A tiny server: /events needs the access token "access2"; /auth/refresh
/// accepts the refresh token "refresh1" once.
class _FakeServer implements HttpClientAdapter {
  int refreshCalls = 0;
  bool refreshWorks = true;
  bool offlineOnRefresh = false;
  final seen = <String>[];

  ResponseBody _json(int status, Object body) => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    seen.add('${options.path} ${options.headers['Authorization']}');

    if (options.path == '/auth/refresh') {
      refreshCalls++;
      if (offlineOnRefresh) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final sent = (options.data as Map)['refreshToken'];
      if (refreshWorks && sent == 'refresh1') {
        return _json(200, {'token': 'access2', 'refreshToken': 'refresh2'});
      }
      return _json(401, {'message': 'expired'});
    }

    if (options.headers['Authorization'] == 'Bearer access2') {
      return _json(200, {'ok': true});
    }
    return _json(401, {'message': 'unauthorized'});
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _MemoryStorage storage;
  late _FakeServer server;
  late ProviderContainer container;
  late Dio dio;

  setUp(() {
    storage = _MemoryStorage()
      ..access = 'access1'
      ..refresh = 'refresh1';
    server = _FakeServer();
    container = ProviderContainer(
      overrides: [
        tokenProvider.overrideWithValue(storage),
        authProvider.overrideWith(_SignedOut.new),
      ],
    );
    dio = container.read(dioProvider)..httpClientAdapter = server;
  });

  tearDown(() => container.dispose());

  test('a 401 refreshes the tokens and repeats the request', () async {
    final response = await dio.get('/events');

    expect(response.statusCode, 200);
    expect(server.refreshCalls, 1);
    expect(storage.access, 'access2');
    expect(storage.refresh, 'refresh2');
    // Tried with the old token, refreshed, then repeated with the new one.
    expect(server.seen.first, '/events Bearer access1');
    expect(server.seen.last, '/events Bearer access2');
  });

  test('several requests failing at once refresh only once', () async {
    final results = await Future.wait([
      dio.get('/events'),
      dio.get('/events'),
      dio.get('/events'),
    ]);

    expect(results.map((r) => r.statusCode), [200, 200, 200]);
    // The refresh token works once: a second refresh would end the session.
    expect(server.refreshCalls, 1);
  });

  test('when the refresh token is refused the user is signed out', () async {
    server.refreshWorks = false;

    await expectLater(
      dio.get('/events'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          401,
        ),
      ),
    );

    expect(storage.access, isNull);
    expect(storage.refresh, isNull);
  });

  test('being offline during the refresh does not sign the user out', () async {
    server.offlineOnRefresh = true;

    await expectLater(dio.get('/events'), throwsA(isA<DioException>()));

    expect(storage.access, 'access1');
    expect(storage.refresh, 'refresh1');
  });

  test('without a refresh token a 401 signs out', () async {
    storage.refresh = null;

    await expectLater(dio.get('/events'), throwsA(isA<DioException>()));

    expect(server.refreshCalls, 0);
    expect(storage.access, isNull);
  });

  test('a 401 from login is not refreshed', () async {
    await expectLater(dio.post('/auth/login'), throwsA(isA<DioException>()));

    expect(server.refreshCalls, 0);
    expect(storage.access, 'access1');
  });
}
