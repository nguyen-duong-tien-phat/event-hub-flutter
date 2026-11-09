import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/app_theme.dart';
import 'package:event_hub_mobile/features/auth/data/models/user.dart';
import 'package:event_hub_mobile/features/organizer/data/models/check_in_result.dart';
import 'package:event_hub_mobile/features/organizer/presentation/screens/check_in_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _show(WidgetTester tester, CheckInResult result) =>
    tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: CheckInResultScreen(result: result),
      ),
    );

void main() {
  testWidgets('admitted shows the ticket and the way to scan the next one', (tester) async {
    await _show(
      tester,
      CheckInResult(
        status: CheckInStatus.admitted,
        eventTitle: 'Midnight Echoes',
        ticketType: 'VIP',
        shortCode: 'K7Q49XMD',
        checkedInAt: DateTime(2030, 1, 1, 19, 42),
      ),
    );

    expect(find.text('Admitted'), findsOneWidget);
    expect(find.text('Midnight Echoes'), findsOneWidget);
    expect(find.text('VIP'), findsOneWidget);
    expect(find.text('K7Q4 9XMD'), findsOneWidget);
    expect(find.text('Scan next'), findsOneWidget);
  });

  testWidgets('already used says when the ticket first got in', (tester) async {
    await _show(
      tester,
      CheckInResult(
        status: CheckInStatus.alreadyUsed,
        ticketType: 'VIP',
        shortCode: 'K7Q49XMD',
        checkedInAt: DateTime(2030, 1, 1, 19, 42),
      ),
    );

    expect(find.text('Already used'), findsOneWidget);
    expect(find.textContaining('7:42 PM'), findsWidgets);
  });

  testWidgets('a refusal explains why', (tester) async {
    for (final (status, heading) in const [
      (CheckInStatus.notPaid, 'Not paid'),
      (CheckInStatus.forbidden, 'Not your event'),
      (CheckInStatus.invalid, 'Not a valid ticket'),
    ]) {
      await _show(tester, CheckInResult(status: status));
      expect(find.text(heading), findsOneWidget);
    }
  });

  test('organizers and admins start on the events tab, attendees on home', () {
    expect(AppRoutes.homeFor(UserRole.attendee), AppRoutes.home);
    expect(AppRoutes.homeFor(UserRole.organizer), AppRoutes.orgEvents);
    expect(AppRoutes.homeFor(UserRole.admin), AppRoutes.orgEvents);
  });
}
