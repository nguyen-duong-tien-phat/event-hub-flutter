import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/app_navigation_bar.dart';
import 'package:event_hub_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:event_hub_mobile/features/events/data/models/event_summary.dart';
import 'package:event_hub_mobile/features/events/presentation/providers/events_provider.dart';
import 'package:event_hub_mobile/features/events/presentation/widgets/event_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // Screen gutter from the design.
  static const double _gutter = 20;

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
      body = _MessageState(
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
      body = _MessageState(
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
            padding: EdgeInsets.symmetric(horizontal: HomeScreen._gutter),
            child: _SectionHeader(
              'Featured Events',
              icon: LucideIcons.star,
              tone: _SectionTone.accent,
            ),
          ),

          SizedBox(height: 14),
          _FeaturedEvents(),

          SizedBox(height: 28),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: HomeScreen._gutter),
            child: _SectionHeader(
              'Upcoming Events',
              icon: LucideIcons.calendar,
              tone: _SectionTone.amber,
            ),
          ),

          SizedBox(height: 14),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: HomeScreen._gutter),
            child: _UpcomingEvents(),
          ),
        ],
      ),
    );
  }
}

/// Centered message used for the empty and error states of Home.
class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        // The bottom padding lifts the block above the true center.
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEFEEEA),
              ),
              child: Icon(icon, size: 28, color: const Color(0xFF3F434A)),
            ),
            const SizedBox(height: 20),
            Text(title, style: context.title, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: context.bodySmall.copyWith(color: context.muted),
              ),
            ),
            const SizedBox(height: 24),
            action,
          ],
        ),
      ),
    );
  }
}

/// Colors for the small icon chip in front of a section title.
enum _SectionTone {
  accent(foreground: null, background: null),
  amber(foreground: Color(0xFF9A5B00), background: Color(0xFFFBF1E0));

  const _SectionTone({required this.foreground, required this.background});

  /// Null means "use the theme accent".
  final Color? foreground;
  final Color? background;
}

/// Section title with an icon chip and a "See all" link to Discover.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {required this.icon, required this.tone});

  final String title;
  final IconData icon;
  final _SectionTone tone;

  @override
  Widget build(BuildContext context) {
    final foreground = tone.foreground ?? context.accent;
    final background =
        tone.background ?? context.accent.withValues(alpha: 0.09);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 10,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: foreground),
            ),
            Text(title, style: context.headline),
          ],
        ),
        // Accent text + chevron: reads as a link without a background.
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: context.accent,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            iconSize: 14,
          ),
          onPressed: () => context.push(AppRoutes.discover),
          iconAlignment: IconAlignment.end,
          icon: const Icon(LucideIcons.chevronRight),
          label: Text(
            'See all',
            // Theme text styles carry their own color, which would win over
            // the button's foregroundColor, so set it here too.
            style: context.fieldLabel.copyWith(color: context.accent),
          ),
        ),
      ],
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
        horizontal: HomeScreen._gutter,
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
