import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/skeleton.dart';
import 'package:event_hub_mobile/core/widgets/skeleton_pulse.dart';
import 'package:event_hub_mobile/features/events/data/models/event_summary.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum EventItemVariant { featured, compact }

class EventItem extends StatelessWidget {
  final EventItemVariant? variant;

  /// Null when this item is a loading skeleton.
  final EventSummary? event;

  const new({
    super.key,
    required this.event,
    this.variant = EventItemVariant.compact,
  });

  @override
  Widget build(BuildContext context) {
    // Copy to a local variable so Dart can promote it to non-null below.
    final event = this.event;

    if (event == null) {
      return SkeletonPulse(
        child: variant == EventItemVariant.featured
            ? const _FeaturedSkeleton()
            : const _CompactSkeleton(),
      );
    }

    if (variant == EventItemVariant.featured) {
      return SizedBox(
        width: 280,
        child: Column(
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
                    width: 44,
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        Text(
                          event.month.toUpperCase(),
                          style: context.dateBadgeMonth.copyWith(
                            color: context.accent,
                          ),
                        ),
                        Text(
                          event.day,
                          style: context.cardTitle.copyWith(height: 1.1),
                        ),
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
                    alignment: Alignment.center,
                    child: const Icon(LucideIcons.heart, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(event.title, style: context.subhead),
            const SizedBox(height: 4),
            Text(
              '${event.location} · ${event.time}',
              style: context.meta.copyWith(color: context.muted),
            ),
            const SizedBox(height: 6),
            Text(event.organizer.fullName, style: context.metaStrong),
          ],
        ),
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
            spacing: 3,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${event.date} · ${event.time}',
                style: context.dateLine.copyWith(color: context.accent),
              ),
              Text(
                event.title,
                style: context.bodyStrong,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                event.organizer.fullName,
                style: context.meta.copyWith(color: context.muted),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(LucideIcons.heart, size: 20, color: context.muted),
        ),
      ],
    );
  }
}

/// Mirrors the featured layout: 280x180 image, then three text lines.
class _FeaturedSkeleton extends StatelessWidget {
  const _FeaturedSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(width: 280, height: 180, radius: 16), // image
          SizedBox(height: 12),
          Skeleton(width: 200, height: 16), // title
          SizedBox(height: 8),
          Skeleton(width: 160, height: 12), // location · time
          SizedBox(height: 10),
          Skeleton(width: 110, height: 12), // organizer
        ],
      ),
    );
  }
}

/// Mirrors the compact layout: 64x64 image, three lines, heart space.
class _CompactSkeleton extends StatelessWidget {
  const _CompactSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      spacing: 14,
      children: [
        Skeleton(width: 64, height: 64, radius: 12), // image
        Expanded(
          child: Column(
            spacing: 6,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(width: 110, height: 12), // date · time
              Skeleton(height: 14, width: 200), // title
              Skeleton(width: 120, height: 12), // organizer
            ],
          ),
        ),
        SizedBox(width: 36), // same space as the heart icon + padding
      ],
    );
  }
}
