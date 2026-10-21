import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/app_navigation_bar.dart';
import 'package:event_hub_mobile/core/widgets/message_state.dart';
import 'package:event_hub_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:event_hub_mobile/features/events/data/models/event_summary.dart';
import 'package:event_hub_mobile/features/events/presentation/providers/events_provider.dart';
import 'package:event_hub_mobile/features/events/presentation/widgets/event_item.dart';
import 'package:event_hub_mobile/features/events/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Screen gutter from the design.
const double _gutter = 20;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// An error that is final, not one carried over while a retry is loading.
  static bool _failed(AsyncValue<List<EventSummary>> events) =>
      events.hasError && !events.isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredEventsProvider);
    final upcoming = ref.watch(upcomingEventsProvider);

    // Whole-screen states only when there is nothing useful to show: if one
    // section loaded, its events stay and the other shows its own message.
    final bothFailed = _failed(featured) && _failed(upcoming);
    final bothEmpty =
        (featured.value?.isEmpty ?? false) &&
        (upcoming.value?.isEmpty ?? false);

    final Widget body;
    if (bothFailed) {
      body = MessageState(
        icon: LucideIcons.wifiOff,
        title: 'Couldn’t load events',
        message: 'Check your connection and try again.',
        action: AppButton(
          label: 'Try again',
          variant: AppButtonVariant.dark,
          onPressed: () {
            ref.invalidate(featuredEventsProvider);
            ref.invalidate(upcomingEventsProvider);
          },
        ),
      );
    } else if (bothEmpty) {
      body = MessageState(
        icon: LucideIcons.calendar,
        title: 'No events near you yet',
        message:
            'Nothing has been posted around here so far. Browse everything '
            'that’s on, or change the location in Filters.',
        action: AppButton(
          label: 'Browse all events',
          variant: AppButtonVariant.secondary,
          onPressed: () => context.push(AppRoutes.discover),
        ),
      );
    } else {
      body = const _HomeSections();
    }

    return Scaffold(
      bottomNavigationBar: const AppNavigationBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Hello(),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

/// The normal Home content: Featured and Upcoming sections.
class _HomeSections extends StatelessWidget {
  const _HomeSections();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _gutter),
            child: SectionHeader(
              'Featured Events',
              icon: LucideIcons.star,
              tone: SectionTone.accent,
            ),
          ),

          SizedBox(height: 14),
          _FeaturedEvents(),

          SizedBox(height: 28),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: _gutter),
            child: SectionHeader(
              'Upcoming Events',
              icon: LucideIcons.calendar,
              tone: SectionTone.amber,
            ),
          ),

          SizedBox(height: 14),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _gutter),
            child: _UpcomingEvents(),
          ),
        ],
      ),
    );
  }
}

class _Hello extends ConsumerWidget {
  const _Hello();

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 18) return 'Afternoon';
    return 'Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final firstName = user?.fullName.trim().split(' ').first ?? '';

    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(
        vertical: 20,
        horizontal: _gutter,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          // "Evening, Alex": the name is set larger, in an italic serif and
          // the accent color.
          Text.rich(
            TextSpan(
              text: firstName.isEmpty ? greeting() : '${greeting()}, ',
              children: [
                if (firstName.isNotEmpty)
                  TextSpan(
                    text: firstName,
                    style: TextStyle(
                      fontFamily: 'InstrumentSerif',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      fontSize: 40,
                      letterSpacing: -0.4,
                      color: context.accent,
                    ),
                  ),
              ],
            ),
            style: context.display.copyWith(height: 1.15),
          ),
          Text(
            'Find something worth going out for.',
            style: context.bodySmall.copyWith(color: context.muted),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: _gutter),
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
