import 'package:event_hub_mobile/core/network/api_exception.dart';
import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/app_header.dart';
import 'package:event_hub_mobile/core/widgets/message_state.dart';
import 'package:event_hub_mobile/features/events/data/models/event_summary.dart';
import 'package:event_hub_mobile/features/events/presentation/providers/discover_providers.dart';
import 'package:event_hub_mobile/features/events/presentation/widgets/event_item.dart';
import 'package:event_hub_mobile/features/events/presentation/widgets/filter_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Every upcoming event, narrowed down with filters. "See all" on Home opens it.
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(discoverFiltersProvider);
    final results = ref.watch(eventResultsProvider(filters, ''));

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text('Discover', style: context.display),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              spacing: 10,
              children: [
                Expanded(child: _SearchTile()),
                FiltersButton(query: ''),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const QuickFilterChips(),
          Expanded(
            child: results.when(
              skipLoadingOnReload: true,
              loading: () => const EventList.loading(),
              error: (error, _) => MessageState(
                icon: LucideIcons.wifiOff,
                title: 'Couldn’t load events',
                message: error is ApiException
                    ? error.message
                    : 'Check your connection and try again.',
                action: AppButton(
                  label: 'Try again',
                  variant: AppButtonVariant.dark,
                  onPressed: () =>
                      ref.invalidate(eventResultsProvider(filters, '')),
                ),
              ),
              data: (page) => page.items.isEmpty
                  ? MessageState(
                      icon: LucideIcons.calendar,
                      title: 'No events match',
                      message: filters.isEmpty
                          ? 'There are no upcoming events right now.'
                          : 'Nothing fits those filters. Try fewer filters.',
                      action: filters.isEmpty
                          ? const SizedBox.shrink()
                          : AppButton(
                              label: 'Clear filters',
                              variant: AppButtonVariant.secondary,
                              onPressed: () => ref
                                  .read(discoverFiltersProvider.notifier)
                                  .reset(),
                            ),
                    )
                  : EventList(
                      events: page.items,
                      total: page.totalCount,
                      onRefresh: () =>
                          ref.refresh(eventResultsProvider(filters, '').future),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Looks like a search field; tapping it opens the search screen.
class _SearchTile extends StatelessWidget {
  const _SearchTile();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.line),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () => context.push(AppRoutes.search),
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              spacing: 10,
              children: [
                Icon(LucideIcons.search, size: 18, color: context.muted),
                Expanded(
                  child: Text(
                    'Search events, venues, artists',
                    style: context.body.copyWith(
                      color: const Color(0xFF8A8E94),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "N events" over a list of compact event rows (with prices).
class EventList extends StatelessWidget {
  const EventList({
    super.key,
    required List<EventSummary> this.events,
    required int this.total,
    this.onRefresh,
  });

  const EventList.loading({super.key})
    : events = null,
      total = null,
      onRefresh = null;

  final List<EventSummary>? events;
  final int? total;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final events = this.events;

    final list = ListView(
      physics: events == null ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        if (events != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              '$total ${total == 1 ? 'event' : 'events'}',
              style: context.meta.copyWith(color: context.muted),
            ),
          ),
        if (events == null)
          for (var i = 0; i < 5; i++) ...[
            const EventItem(event: null),
            const SizedBox(height: 18),
          ]
        else
          for (final event in events) ...[
            EventItem(event: event, showPrice: true, showVenue: true),
            const SizedBox(height: 18),
          ],
      ],
    );

    return onRefresh == null
        ? list
        : RefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}
