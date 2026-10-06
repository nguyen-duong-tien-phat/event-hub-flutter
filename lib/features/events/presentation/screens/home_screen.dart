import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/app_navigation_bar.dart';
import 'package:event_hub_mobile/core/widgets/app_text_field.dart';
import 'package:event_hub_mobile/features/events/presentation/providers/events_provider.dart';
import 'package:event_hub_mobile/features/events/presentation/widgets/event_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Screen gutter from the design.
  static const double _gutter = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppNavigationBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(_gutter, 8, _gutter, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        spacing: 2,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Events near',
                            style: context.caption.copyWith(
                              color: context.muted,
                            ),
                          ),
                          Row(
                            spacing: 4,
                            children: [
                              Text(
                                'San Francisco, US',
                                style: context.bodyStrong,
                              ),
                              Icon(
                                LucideIcons.chevronDown,
                                size: 16,
                                color: context.muted,
                              ),
                            ],
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: context.accent.withValues(alpha: 0.07),
                        child: Text(
                          'FN',
                          style: context.link.copyWith(color: context.accent),
                        ),
                      ),
                    ],
                  ),

                  // BODY
                  Padding(
                    padding: const EdgeInsets.only(top: 18, bottom: 16),
                    child: Text('Discover', style: context.display),
                  ),

                  // SEARCH
                  Row(
                    children: [
                      const Expanded(
                        child: AppTextField(
                          hint: 'Search events, venues, artists',
                          prefixIcon: Icon(LucideIcons.search),
                        ),
                      ),

                      const SizedBox(width: 10),

                      AppButton.icon(
                        tooltip: 'Filter',
                        variant: AppButtonVariant.secondary,
                        icon: LucideIcons.sliders,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Padding goes on the scroll view, not around it, so chips
            // line up with the gutter but still scroll to the screen edge.
            // const SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   padding: EdgeInsets.symmetric(horizontal: _gutter),
            //   child: CategoryChips(
            //     categories: ['My feed', 'Concerts', 'Food', 'Art'],
            //   ),
            // ),
            // const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: _gutter),
                      child: Text('Featured Events', style: context.headline),
                    ),

                    const SizedBox(height: 14),
                    const _FeaturedEvents(),

                    const SizedBox(height: 28),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: _gutter),
                      child: Text('Upcoming Events', style: context.headline),
                    ),

                    const SizedBox(height: 14),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: _gutter),
                      child: _UpcomingEvents(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedEvents extends ConsumerWidget {
  const _FeaturedEvents();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredEventsProvider);

    final children = featured.when(
      data: (events) => events.isEmpty
          ? [Text('No events this week', style: context.caption)]
          : [
              for (final event in events)
                EventItem(event: event, variant: EventItemVariant.featured),
            ],
      error: (error, stackTrace) {
        debugPrint('❌ featuredEvents: $error');
        debugPrint('$stackTrace');
        return [
          Text('Could not load events', style: context.caption),
          TextButton(
            onPressed: () => ref.invalidate(featuredEventsProvider),
            child: const Text('Retry'),
          ),
        ];
      },
      loading: () => [
        for (var i = 0; i < 3; i++)
          const EventItem(event: null, variant: EventItemVariant.featured),
      ],
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: HomeScreen._gutter),
      child: Row(spacing: 10, children: children),
    );
  }
}

class _UpcomingEvents extends ConsumerWidget {
  const _UpcomingEvents();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(upcomingEventsProvider);

    final children = featured.when(
      data: (events) => events.isEmpty
          ? [Text('No events upcoming', style: context.caption)]
          : [for (final event in events) EventItem(event: event)],
      error: (error, stackTrace) {
        debugPrint('❌ upcomingEvents: $error');
        debugPrint('$stackTrace');
        return [
          Text('Could not load events', style: context.caption),
          TextButton(
            onPressed: () => ref.invalidate(upcomingEventsProvider),
            child: const Text('Retry'),
          ),
        ];
      },
      loading: () => [for (var i = 0; i < 3; i++) const EventItem(event: null)],
    );

    return Column(spacing: 10, children: children);
  }
}
