import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:event_hub_mobile/core/network/api_client.dart';
import 'package:event_hub_mobile/features/organizer/data/models/check_in_result.dart';
import 'package:event_hub_mobile/features/organizer/data/organizer_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers every request with one status and body, and remembers the request.
class _Server implements HttpClientAdapter {
  _Server(this.status, this.body);

  final int status;
  final Object? body;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

OrganizerRepository _repo(_Server server) {
  final dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
    ..httpClientAdapter = server;
  return OrganizerRepository(ApiClient(dio));
}

void main() {
  test('check-in: 200 is admitted and the code is sent as the request body', () async {
    final server = _Server(200, {
      'status': 'Admitted',
      'eventTitle': 'Midnight Echoes',
      'ticketType': 'VIP',
      'shortCode': 'K7Q49XMD',
      'checkedInAt': '2030-01-01T19:42:00Z',
    });

    final result = await _repo(server).checkIn('eh2.abc.def');

    expect(result.status, CheckInStatus.admitted);
    expect(result.ticketType, 'VIP');
    expect(server.last!.path, '/checkin');
    expect(server.last!.data, {'code': 'eh2.abc.def'});
  });

  test('check-in: 409 is an answer, not an error (already used)', () async {
    final server = _Server(409, {
      'status': 'AlreadyUsed',
      'ticketType': 'VIP',
      'checkedInAt': '2030-01-01T19:42:00Z',
    });

    final result = await _repo(server).checkIn('K7Q49XMD');

    expect(result.status, CheckInStatus.alreadyUsed);
    expect(result.timeLabel, isNotNull);
  });

  test('check-in: 403 with a body is "not your event"', () async {
    final server = _Server(403, {'status': 'Forbidden'});

    expect((await _repo(server).checkIn('x')).status, CheckInStatus.forbidden);
  });

  test('check-in: 400 is a code that is not a ticket', () async {
    final server = _Server(400, {'status': 'Invalid'});

    expect((await _repo(server).checkIn('nope')).status, CheckInStatus.invalid);
  });

  test('check-in: an answer without a status counts as not valid', () async {
    final server = _Server(400, {'errors': {'Code': ['The Code field is required.']}});

    expect((await _repo(server).checkIn('')).status, CheckInStatus.invalid);
  });

  test('sales: asks for the first page and reads the summary', () async {
    final server = _Server(200, {
      'summary': {
        'events': 0,
        'upcoming': 0,
        'past': 0,
        'ticketsSold': 0,
        'ticketRevenue': 0,
        'checkedIn': 0,
        'ticketsSoldOfPastEvents': 0,
      },
      'events': {'items': <Object>[]},
    });

    final sales = await _repo(server).sales();

    expect(server.last!.path, '/events/sales');
    expect(server.last!.queryParameters['page'], 1);
    expect(sales.events, isEmpty);
  });

  test('admissions: only the filters that are set are sent', () async {
    final server = _Server(200, {
      'items': <Object>[],
      'page': 1,
      'pageSize': 20,
      'totalCount': 0,
      'totalPages': 0,
    });

    await _repo(server).admissions('e1', checkedIn: true, search: '');

    expect(server.last!.path, '/events/e1/admissions');
    expect(server.last!.queryParameters['checkedIn'], true);
    expect(server.last!.queryParameters.containsKey('search'), isFalse);
  });
}
