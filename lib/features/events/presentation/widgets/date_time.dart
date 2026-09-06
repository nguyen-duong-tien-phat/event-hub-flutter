import 'package:event_hub_mobile/core/theme/app_theme.dart';
import 'package:event_hub_mobile/features/events/data/models/event.dart';
import 'package:flutter/material.dart';

class DateTimeWidget extends StatelessWidget {
  final Event event;

  const DateTimeWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 15,
              color: AppColors.accent,
            ),
            const SizedBox(width: 7),
            Text(
              '${event.weekdayFull}, ${event.monthAbbreviated} ${event.dayNumber}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 15,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 7),
            Text(
              event.formattedTime,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}
