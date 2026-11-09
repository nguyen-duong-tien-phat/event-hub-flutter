import 'package:event_hub_mobile/features/organizer/data/models/check_in_result.dart';
import 'package:event_hub_mobile/features/organizer/data/models/event_admission.dart';
import 'package:event_hub_mobile/features/organizer/data/models/event_stats.dart';
import 'package:event_hub_mobile/features/organizer/data/models/managed_booking.dart';
import 'package:event_hub_mobile/features/organizer/data/models/sales.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _event(String id, DateTime startsAt, {int sold = 10}) => {
  'id': id,
  'title': 'Event $id',
  'startsAt': startsAt.toUtc().toIso8601String(),
  'location': 'The Fillmore',
  'imageUrl': 'https://img/$id.png',
  'category': 'Concert',
  'totalQuantity': 100,
  'remainingQuantity': 100 - sold,
  'ticketsSold': sold,
  'ticketRevenue': 250,
  'checkedIn': 3,
};

void main() {
  test('sales: the summary is read and events split into upcoming and past', () {
    final sales = Sales.fromJson({
      'summary': {
        'events': 3,
        'upcoming': 2,
        'past': 1,
        'ticketsSold': 30,
        'ticketRevenue': 750.5,
        'checkedIn': 9,
        'ticketsSoldOfPastEvents': 12,
      },
      'events': {
        'items': [
          _event('later', DateTime.now().add(const Duration(days: 9))),
          _event('soon', DateTime.now().add(const Duration(days: 2))),
          _event('old', DateTime.now().subtract(const Duration(days: 5))),
        ],
      },
    });

    expect(sales.summary.ticketRevenue, 750.5);
    expect(sales.summary.attendanceRate, 0.75);
    // Upcoming: the nearest first. Past: as the backend sent them.
    expect(sales.upcoming.map((e) => e.id), ['soon', 'later']);
    expect(sales.past.map((e) => e.id), ['old']);
    expect(sales.events.first.soldFraction, 0.1);
  });

  test('sales: no attendance rate while no past event sold a ticket', () {
    final summary = SalesSummary.fromJson({
      'events': 1,
      'upcoming': 1,
      'past': 0,
      'ticketsSold': 0,
      'ticketRevenue': 0,
      'checkedIn': 0,
      'ticketsSoldOfPastEvents': 0,
    });

    expect(summary.attendanceRate, isNull);
  });

  test('stats: bookings by status, ticket types and the held total', () {
    final stats = EventStats.fromJson({
      'eventId': 'e1',
      'bookings': {'pending': 2, 'confirmed': 5, 'cancelled': 1},
      'ticketRevenue': 125,
      'serviceFees': 1.25,
      'ticketsSold': 5,
      'checkedIn': 2,
      'tickets': [
        {
          'ticketId': 't1',
          'type': 'General',
          'price': 25,
          'totalQuantity': 10,
          'remainingQuantity': 3,
          'sold': 5,
          'held': 2,
        },
        {
          'ticketId': 't2',
          'type': 'VIP',
          'price': 60,
          'totalQuantity': 4,
          'remainingQuantity': 4,
          'sold': 0,
          'held': 1,
        },
      ],
    });

    expect(stats.confirmed, 5);
    expect(stats.held, 3);
    expect(stats.tickets.first.soldFraction, 0.5);
  });

  test('admission: the short code is shown in two groups and the time local', () {
    final a = EventAdmission.fromJson({
      'id': 'a1',
      'ticketType': 'VIP',
      'shortCode': 'K7Q49XMD',
      'checkedInAt': '2030-01-01T19:42:00Z',
      'bookingId': 'b1',
      'buyer': {'id': 'u1', 'fullName': 'Alex Lee', 'email': 'a@b.c'},
    });

    expect(a.codeLabel, 'K7Q4 9XMD');
    expect(a.checkedIn, isTrue);
    expect(a.buyerName, 'Alex Lee');
  });

  test('admission: someone who has not been scanned is not checked in', () {
    final a = EventAdmission.fromJson({
      'id': 'a1',
      'ticketType': 'General',
      'shortCode': 'K7Q49XMD',
      'checkedInAt': null,
      'bookingId': 'b1',
      'buyer': {'id': 'u1', 'fullName': 'Alex Lee', 'email': 'a@b.c'},
    });

    expect(a.checkedIn, isFalse);
    expect(a.checkedInTime, isNull);
  });

  test('managed booking: tickets are summed up in one line, status is read', () {
    final b = ManagedBooking.fromJson({
      'id': 'b1',
      'eventId': 'e1',
      'event': {'id': 'e1', 'title': 'Midnight Echoes', 'imageUrl': 'u'},
      'tickets': [
        {'ticketId': 't1', 'type': 'VIP', 'quantity': 2},
        {'ticketId': 't2', 'type': 'General', 'quantity': 1},
      ],
      'totalPrice': 121.2,
      'status': 'Confirmed',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'buyer': {'id': 'u1', 'fullName': 'Alex Lee', 'email': 'a@b.c'},
    });

    expect(b.itemsLabel, '2 × VIP, 1 × General');
    expect(b.status, ManagedBookingStatus.confirmed);
    expect(b.whenLabel, startsWith('Today'));
  });

  test('check-in result: every status the API sends is understood', () {
    for (final (name, expected) in const [
      ('Admitted', CheckInStatus.admitted),
      ('AlreadyUsed', CheckInStatus.alreadyUsed),
      ('NotPaid', CheckInStatus.notPaid),
      ('Invalid', CheckInStatus.invalid),
      ('Forbidden', CheckInStatus.forbidden),
    ]) {
      expect(CheckInResult.fromJson({'status': name}).status, expected);
    }
  });

  test('check-in result: an unknown status counts as not valid', () {
    expect(
      CheckInResult.fromJson({'status': 'Something new'}).status,
      CheckInStatus.invalid,
    );
  });

  test('check-in result: the ticket details are kept', () {
    final r = CheckInResult.fromJson({
      'status': 'AlreadyUsed',
      'eventTitle': 'Midnight Echoes',
      'ticketType': 'VIP',
      'shortCode': 'K7Q49XMD',
      'checkedInAt': '2030-01-01T19:42:00Z',
    });

    expect(r.eventTitle, 'Midnight Echoes');
    expect(r.codeLabel, 'K7Q4 9XMD');
    expect(r.timeLabel, isNotNull);
  });
}
