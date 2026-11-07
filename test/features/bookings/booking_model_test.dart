import 'package:event_hub_mobile/features/bookings/data/models/booking.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _json(Map<String, dynamic> extra) => {
  'id': 'booking-1',
  'eventId': 'e1',
  'tickets': <Object>[],
  'quantity': 2,
  'subtotal': 20,
  'serviceFee': 0.2,
  'totalPrice': 20.2,
  'status': 'Confirmed',
  'createdAt': '2030-01-01T10:00:00Z',
  'expiresAt': '2030-01-01T10:15:00Z',
  ...extra,
};

void main() {
  test('parses the admissions, who is checked in, and canCancel', () {
    final booking = Booking.fromJson(
      _json({
        'admissions': [
          {
            'id': 'adm_1',
            'ticketType': 'VIP',
            'code': 'eh2.adm_1.sig',
            'shortCode': 'K7Q49XMD',
            'checkedInAt': '2030-01-02T19:42:00Z',
          },
          {
            'id': 'adm_2',
            'ticketType': 'VIP',
            'code': 'eh2.adm_2.sig',
            'shortCode': 'ABCD2345',
            'checkedInAt': null,
          },
        ],
        'checkedInCount': 1,
        'canCancel': false,
      }),
    );

    expect(booking.admissions, hasLength(2));
    expect(booking.admissions[0].isCheckedIn, isTrue);
    expect(booking.admissions[1].isCheckedIn, isFalse);
    expect(booking.admissions[0].shortCodeLabel, 'K7Q4 9XMD');
    expect(booking.admissions[0].code, 'eh2.adm_1.sig');
    expect(booking.checkedInCount, 1);
    expect(booking.canCancel, isFalse);
  });

  test(
    'a booking without admissions (not paid yet) has none and can be cancelled',
    () {
      final booking = Booking.fromJson(_json({'status': 'Pending'}));

      expect(booking.admissions, isEmpty);
      expect(booking.checkedInCount, 0);
      expect(booking.canCancel, isTrue);
    },
  );
}
