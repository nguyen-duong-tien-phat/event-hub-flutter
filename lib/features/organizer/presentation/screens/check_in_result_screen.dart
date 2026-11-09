import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/features/organizer/data/models/check_in_result.dart';
import 'package:event_hub_mobile/features/organizer/presentation/widgets/organizer_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// What the person at the door needs to see after a scan: did the guest get
/// in, and if not, why.
class CheckInResultScreen extends StatelessWidget {
  const CheckInResultScreen({super.key, required this.result});

  final CheckInResult result;

  @override
  Widget build(BuildContext context) {
    final (icon, heading, line, soft, ink) = switch (result.status) {
      CheckInStatus.admitted => (
        LucideIcons.circleCheck,
        'Admitted',
        null,
        OrgColors.successSoft,
        context.success,
      ),
      CheckInStatus.alreadyUsed => (
        LucideIcons.circleAlert,
        'Already used',
        'This ticket got in at ${result.timeLabel ?? 'an earlier scan'}.',
        OrgColors.warningSoft,
        OrgColors.warning,
      ),
      CheckInStatus.notPaid => (
        LucideIcons.circleAlert,
        'Not paid',
        'The booking for this ticket has not been paid.',
        OrgColors.warningSoft,
        OrgColors.warning,
      ),
      CheckInStatus.forbidden => (
        LucideIcons.circleX,
        'Not your event',
        'This ticket is for an event you do not manage.',
        OrgColors.dangerSoft,
        context.danger,
      ),
      CheckInStatus.invalid => (
        LucideIcons.circleX,
        'Not a valid ticket',
        'This code is not one of ours. Check it and try again.',
        OrgColors.dangerSoft,
        context.danger,
      ),
    };

    final rows = <(String, String)>[
      if (result.ticketType != null) ('Ticket', result.ticketType!),
      if (result.codeLabel != null) ('Code', result.codeLabel!),
      if (result.status == CheckInStatus.admitted && result.timeLabel != null)
        ('Time', result.timeLabel!),
      if (result.status == CheckInStatus.alreadyUsed &&
          result.timeLabel != null)
        ('First scanned', result.timeLabel!),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
                child: Column(
                  spacing: 14,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: soft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 44, color: ink),
                    ),
                    Text(
                      heading,
                      textAlign: TextAlign.center,
                      style: context.display.copyWith(color: ink),
                    ),
                    if (line != null)
                      Text(
                        line,
                        textAlign: TextAlign.center,
                        style: context.body.copyWith(color: OrgColors.inkSoft),
                      ),
                    if (result.eventTitle != null)
                      Text(result.eventTitle!, style: context.bodyStrong),
                    if (rows.isNotEmpty)
                      RowsCard(
                        children: [
                          for (final (k, v) in rows)
                            SizedBox(
                              height: 48,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      k,
                                      style: context.bodySmall.copyWith(
                                        color: context.muted,
                                      ),
                                    ),
                                    Text(
                                      v,
                                      style: context.bodyStrong.copyWith(
                                        fontFamily: k == 'Code'
                                            ? 'Menlo'
                                            : null,
                                        letterSpacing: k == 'Code' ? 1 : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: AppButton(
                label: 'Scan next',
                variant: AppButtonVariant.dark,
                size: AppButtonSize.large,
                expand: true,
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
