import 'dart:math' as math;

import 'package:event_hub_mobile/core/network/api_exception.dart';
import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/bottom_action_bar.dart';
import 'package:event_hub_mobile/core/widgets/message_state.dart';
import 'package:event_hub_mobile/core/widgets/skeleton.dart';
import 'package:event_hub_mobile/core/widgets/skeleton_pulse.dart';
import 'package:event_hub_mobile/features/events/data/models/event.dart';
import 'package:event_hub_mobile/features/events/presentation/providers/events_provider.dart';
import 'package:event_hub_mobile/features/events/presentation/widgets/event_detail/event_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const double _gutter = 20;
const double _heroHeight = 300;

// The sheet with the details overlaps the bottom of the photo by this much.
const double _sheetOverlap = 20;

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventDetailProvider(id));

    return Scaffold(
      body: event.when(
        loading: () => const _Skeleton(),
        error: (error, _) => _ErrorState(
          notFound: error is NotFoundException,
          onRetry: () => ref.invalidate(eventDetailProvider(id)),
        ),
        data: (event) => _Content(event: event),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.event});
  final Event event;

  @override
  Widget build(BuildContext context) {
    final tickets = event.tickets;
    final remaining = tickets.fold<int>(
      0,
      (sum, t) => sum + t.remainingQuantity,
    );
    final total = tickets.fold<int>(0, (sum, t) => sum + t.totalQuantity);
    final soldOut = tickets.isNotEmpty && remaining == 0;
    final fewLeft = !soldOut && total > 0 && remaining / total <= 0.2;
    final cheapest = tickets.isEmpty
        ? null
        : tickets.map((t) => t.price).reduce(math.min);

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _Hero(imageUrl: event.imageUrl),
                Transform.translate(
                  offset: const Offset(0, -_sheetOverlap),
                  child: EventSheet(
                    event: event,
                    soldOut: soldOut,
                    fewLeft: fewLeft,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _TopBar(showActions: true),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _BottomBar(cheapestPrice: cheapest, soldOut: soldOut),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(color: context.line);

    return SizedBox(
      height: _heroHeight,
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder,
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }
}

/// Back / share / save buttons floating over the photo.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.showActions});

  /// Share and save are hidden while the event is loading.
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_gutter, 8, _gutter, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CircleButton(
              icon: LucideIcons.arrowLeft,
              tooltip: 'Back',
              onTap: () => _goBack(context),
            ),
            if (showActions)
              // TODO: wire up sharing and saving.
              const Row(
                spacing: 8,
                children: [
                  _CircleButton(icon: LucideIcons.share, tooltip: 'Share'),
                  _CircleButton(icon: LucideIcons.heart, tooltip: 'Save'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.tooltip, this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surface.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox.square(
            dimension: 40,
            child: Icon(icon, size: 18, color: context.ink),
          ),
        ),
      ),
    );
  }
}

void _goBack(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(AppRoutes.home);

/// The event detail's bottom bar: cheapest ticket price and "Get tickets".
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.cheapestPrice, required this.soldOut});

  final double? cheapestPrice;
  final bool soldOut;

  String _price(double price) => price == 0
      ? 'Free'
      : NumberFormat.currency(symbol: r'$', decimalDigits: 2).format(price);

  @override
  Widget build(BuildContext context) {
    final price = cheapestPrice;

    return BottomActionBar(
      leading: price == null
          ? Text(
              'Tickets not on sale yet',
              style: context.bodySmall.copyWith(color: context.muted),
            )
          : BottomBarLabel(caption: 'From', value: _price(price)),
      actionLabel: soldOut ? 'Sold out' : 'Get tickets',
      // TODO: open the ticket selection screen.
      onPressed: soldOut || price == null ? null : () {},
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.notFound, required this.onRetry});

  /// True for a 404: retrying won't help, so offer a way out instead.
  final bool notFound;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TopBar(showActions: false),
        Expanded(
          child: notFound
              ? MessageState(
                  icon: LucideIcons.calendar,
                  title: 'Event not found',
                  message:
                      'This event may have been removed or the link is '
                      'out of date.',
                  action: AppButton(
                    label: 'Back to events',
                    variant: AppButtonVariant.dark,
                    onPressed: () => context.go(AppRoutes.home),
                  ),
                )
              : MessageState(
                  icon: LucideIcons.wifiOff,
                  title: 'Couldn’t load this event',
                  message: 'Check your connection and try again.',
                  action: AppButton(
                    label: 'Try again',
                    variant: AppButtonVariant.dark,
                    onPressed: onRetry,
                  ),
                ),
        ),
      ],
    );
  }
}

/// Mirrors the layout of [_Content] while the event loads.
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: SkeletonPulse(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  const Skeleton(
                    width: double.infinity,
                    height: _heroHeight,
                    radius: 0,
                  ),
                  Transform.translate(
                    offset: const Offset(0, -_sheetOverlap),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                        _gutter,
                        24,
                        _gutter,
                        0,
                      ),
                      decoration: BoxDecoration(
                        color: context.background,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 20,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12,
                            children: [
                              Skeleton(width: 96, height: 22), // badge
                              Skeleton(width: 280, height: 30), // title
                              Skeleton(width: 200, height: 30),
                            ],
                          ),
                          _InfoRowSkeleton(),
                          _InfoRowSkeleton(),
                          Skeleton(width: 140, height: 18), // about heading
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              Skeleton(height: 14),
                              Skeleton(height: 14),
                              Skeleton(width: 220, height: 14),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Leaving is always possible, even while loading.
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _TopBar(showActions: false),
        ),
      ],
    );
  }
}

class _InfoRowSkeleton extends StatelessWidget {
  const _InfoRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      spacing: 14,
      children: [
        Skeleton(width: 44, height: 44, radius: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Skeleton(width: 160, height: 16),
            Skeleton(width: 100, height: 12),
          ],
        ),
      ],
    );
  }
}
