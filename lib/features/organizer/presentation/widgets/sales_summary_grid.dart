import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/utils/money.dart';
import 'package:event_hub_mobile/features/organizer/data/models/sales.dart';
import 'package:event_hub_mobile/features/organizer/presentation/widgets/organizer_widgets.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The four totals over all of an organizer's events: tickets sold, revenue,
/// guests checked in and how many events there are.
class SalesSummaryGrid extends StatelessWidget {
  const SalesSummaryGrid({super.key, required this.sales});

  final Sales sales;

  @override
  Widget build(BuildContext context) {
    final summary = sales.summary;
    final totalSeats = sales.events.fold<int>(0, (s, e) => s + e.totalQuantity);
    final rate = summary.attendanceRate;

    return Column(
      spacing: 10,
      children: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: StatCard(
                label: 'Tickets sold',
                value: '${summary.ticketsSold}',
                hint: 'of $totalSeats on sale',
                icon: LucideIcons.ticket,
              ),
            ),
            Expanded(
              child: StatCard(
                label: 'Revenue',
                value: formatMoney(summary.ticketRevenue),
                hint: 'tickets, without fees',
                icon: LucideIcons.dollarSign,
                tint: OrgColors.successSoft,
                iconColor: context.success,
              ),
            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: StatCard(
                label: 'Checked in',
                value: '${summary.checkedIn}',
                hint: rate == null
                    ? 'no past events yet'
                    : '${(rate * 100).round()}% of past events',
                icon: LucideIcons.circleCheck,
                tint: OrgColors.successSoft,
                iconColor: context.success,
              ),
            ),
            Expanded(
              child: StatCard(
                label: 'Events',
                value: '${summary.events}',
                hint: '${summary.upcoming} upcoming · ${summary.past} past',
                icon: LucideIcons.calendar,
                tint: OrgColors.warningSoft,
                iconColor: OrgColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
