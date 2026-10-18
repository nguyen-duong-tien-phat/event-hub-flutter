import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_navigation_bar.dart';
import 'package:event_hub_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:event_hub_mobile/features/events/presentation/providers/events_provider.dart';
import 'package:event_hub_mobile/features/events/presentation/widgets/event_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            const _Hello(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: _gutter),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Featured Events', style: context.headline),
                          Text(
                            'See all',
                            style: context.meta.copyWith(
                              color: context.muted,
                              fontWeight: const FontWeight(500),
                            ),
                          ),
                        ],
                      ),
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

class _Hello extends ConsumerWidget {
  const _Hello();

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider).value;
    final username = user?.fullName ?? '';
    final hello = greeting();

    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(
        vertical: 20,
        horizontal: HomeScreen._gutter,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$hello $username', style: context.display),
          Text('Find something worth going out for.', style: context.bodySmall),
        ],
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
