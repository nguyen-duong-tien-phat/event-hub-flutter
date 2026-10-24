import 'package:event_hub_mobile/core/network/api_exception.dart';
import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/message_state.dart';
import 'package:event_hub_mobile/core/widgets/page_title.dart';
import 'package:event_hub_mobile/features/events/data/models/event_summary.dart';
import 'package:event_hub_mobile/features/events/presentation/widgets/event_item.dart';
import 'package:event_hub_mobile/features/saved/presentation/providers/saved_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The Saved tab: events the user has hearted, upcoming first, then past.
class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(savedEventsProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitle('Saved'),
          Expanded(
            child: events.when(
              // Keep the list on screen while it refreshes after an unsave.
              skipLoadingOnReload: true,
              loading: () => ListView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  for (var i = 0; i < 4; i++) ...[
                    const EventItem(event: null),
                    const SizedBox(height: 18),
                  ],
                ],
              ),
              error: (error, _) => MessageState(
                icon: LucideIcons.wifiOff,
                title: 'Couldn’t load your saved events',
                message: error is ApiException
                    ? error.message
                    : 'Check your connection and try again.',
                action: AppButton(
                  label: 'Try again',
                  variant: AppButtonVariant.dark,
                  onPressed: () => ref.invalidate(savedEventsProvider),
                ),
              ),
              data: (events) => events.isEmpty
                  ? MessageState(
                      icon: LucideIcons.heart,
                      title: 'Nothing saved yet',
                      message:
                          'Tap the heart on an event to keep it here for '
                          'later.',
                      action: AppButton(
                        label: 'Discover events',
                        variant: AppButtonVariant.dark,
                        onPressed: () => context.go(AppRoutes.home),
                      ),
                    )
                  : _List(events: events),
            ),
          ),
        ],
      ),
    );
  }
}

class _List extends ConsumerWidget {
  const _List({required this.events});

  final List<EventSummary> events;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now().toUtc();
    final upcoming =
        events.where((e) => e.startsAt.toUtc().isAfter(now)).toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final past = events.where((e) => !e.startsAt.toUtc().isAfter(now)).toList();

    return RefreshIndicator(
      onRefresh: () => ref.refresh(savedEventsProvider.future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          for (final event in upcoming) ...[
            EventItem(event: event, showPrice: true),
            const SizedBox(height: 18),
          ],
          if (past.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'PAST',
              style: context.overline.copyWith(color: context.muted),
            ),
            const SizedBox(height: 12),
            for (final event in past) ...[
              Opacity(opacity: 0.55, child: EventItem(event: event)),
              const SizedBox(height: 18),
            ],
          ],
        ],
      ),
    );
  }
}
