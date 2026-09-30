import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/features/events/data/models/event_summary.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum EventItemVariant { featured, compact }

class EventItem extends StatelessWidget {
  final EventItemVariant? variant;
  final EventSummary event;

  const new({
    super.key,
    required this.event,
    this.variant = EventItemVariant.compact,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == EventItemVariant.featured) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  event.imageUrl,
                  fit: BoxFit.cover,
                  height: 180,
                  width: 280,
                  alignment: Alignment.bottomCenter,
                ),
              ),
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Column(
                    children: [
                      Text(
                        event.month.toUpperCase(),
                        style: context.dateBadgeMonth.copyWith(
                          color: context.accent,
                        ),
                      ),
                      Text(event.day, style: context.cardTitle),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Icon(LucideIcons.heart, size: 18),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(event.title, style: context.subhead),
          Text(
            '${event.location} · ${event.time}',
            style: context.meta.copyWith(color: context.muted),
          ),
          SizedBox(height: 4),
          Text(event.organizer.fullName, style: context.metaStrong),
        ],
      );
    }

    return Row(
      spacing: 14,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            event.imageUrl,
            fit: BoxFit.cover,
            height: 64,
            width: 64,
            alignment: Alignment.bottomCenter,
          ),
        ),

        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${event.date} · ${event.time}',
                style: context.caption.copyWith(
                  color: context.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                event.title,
                style: context.link,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                event.organizer.fullName,
                style: context.caption.copyWith(
                  color: context.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        Icon(LucideIcons.heart),
      ],
    );
  }
}
