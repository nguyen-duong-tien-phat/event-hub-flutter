import 'package:event_hub_mobile/core/network/api_exception.dart';
import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/message_state.dart';
import 'package:event_hub_mobile/core/widgets/page_title.dart';
import 'package:event_hub_mobile/features/bookings/data/models/booking.dart';
import 'package:event_hub_mobile/features/bookings/presentation/providers/booking_providers.dart';
import 'package:event_hub_mobile/features/bookings/presentation/widgets/booking_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The Tickets tab: confirmed bookings, split into upcoming and past.
class MyTicketsScreen extends ConsumerStatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  ConsumerState<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends ConsumerState<MyTicketsScreen> {
  bool _showPast = false;

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(myBookingsProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitle('Tickets'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: _Segments(
              showPast: _showPast,
              onChanged: (past) => setState(() => _showPast = past),
            ),
          ),
          Expanded(
            child: bookings.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _errorState(error),
              data: (all) => _content(all),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState(Object error) {
    // Only attendee accounts can book, so only they have tickets.
    if (error is ForbiddenException) {
      return MessageState(
        icon: LucideIcons.ticket,
        title: 'Tickets are for attendees',
        message:
            'This account can’t book events. Sign in with an attendee '
            'account to see tickets here.',
        action: AppButton(
          label: 'Discover events',
          variant: AppButtonVariant.dark,
          onPressed: () => context.go(AppRoutes.home),
        ),
      );
    }

    return MessageState(
      icon: LucideIcons.wifiOff,
      title: 'Couldn’t load your tickets',
      message: error is ApiException
          ? error.message
          : 'Check your connection and try again.',
      action: AppButton(
        label: 'Try again',
        variant: AppButtonVariant.dark,
        onPressed: () => ref.invalidate(myBookingsProvider),
      ),
    );
  }

  Widget _content(List<Booking> all) {
    final now = DateTime.now().toUtc();
    final confirmed = all
        .where((b) => b.isConfirmed && b.event != null)
        .toList();

    final upcoming =
        confirmed.where((b) => b.event!.startsAt.toUtc().isAfter(now)).toList()
          ..sort((a, b) => a.event!.startsAt.compareTo(b.event!.startsAt));
    final past =
        confirmed.where((b) => !b.event!.startsAt.toUtc().isAfter(now)).toList()
          ..sort((a, b) => b.event!.startsAt.compareTo(a.event!.startsAt));

    final shown = _showPast ? past : upcoming;

    if (shown.isEmpty) {
      return MessageState(
        icon: LucideIcons.ticket,
        title: _showPast ? 'No past tickets' : 'No upcoming tickets',
        message: _showPast
            ? 'Events you’ve been to will show up here.'
            : 'When you book an event, your tickets will show up here, '
                  'ready to scan at the door.',
        action: AppButton(
          label: 'Discover events',
          variant: AppButtonVariant.dark,
          onPressed: () => context.go(AppRoutes.home),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(myBookingsProvider.future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          if (!_showPast) ...[
            Text(
              _nextUpLabel(shown.first.event!.startsAt),
              style: context.overline.copyWith(color: context.muted),
            ),
            const SizedBox(height: 12),
            _NextUpCard(booking: shown.first),
            if (shown.length > 1) ...[
              const SizedBox(height: 20),
              Text(
                'LATER',
                style: context.overline.copyWith(color: context.muted),
              ),
              const SizedBox(height: 12),
            ],
            for (final booking in shown.skip(1)) ...[
              _TicketRow(booking: booking),
              const SizedBox(height: 12),
            ],
          ] else
            for (final booking in shown) ...[
              _TicketRow(booking: booking, faded: true),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  /// "NEXT UP · TODAY", "NEXT UP · TOMORROW" or "NEXT UP · IN 3 DAYS"
  String _nextUpLabel(DateTime startsAt) {
    final today = DateUtils.dateOnly(DateTime.now());
    final day = DateUtils.dateOnly(startsAt.toLocal());
    final days = day.difference(today).inDays;
    final when = switch (days) {
      <= 0 => 'TODAY',
      1 => 'TOMORROW',
      _ => 'IN $days DAYS',
    };
    return 'NEXT UP · $when';
  }
}

class _Segments extends StatelessWidget {
  const _Segments({required this.showPast, required this.onChanged});

  final bool showPast;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget segment(String label, bool past) {
      final selected = showPast == past;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(past),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? context.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: context.ink.withValues(alpha: 0.08),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: context.control.copyWith(
                color: selected ? context.ink : context.muted,
                fontWeight: selected ? FontWeight.w600 : null,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEEEA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [segment('Upcoming', false), segment('Past', true)]),
    );
  }
}

String _countLabel(int n) => '$n ${n == 1 ? 'ticket' : 'tickets'}';

class _NextUpCard extends StatelessWidget {
  const _NextUpCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final event = booking.event!;

    return Material(
      color: context.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: context.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.ticketDetail(booking.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 132,
              width: double.infinity,
              child: Image.network(
                event.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    ColoredBox(color: context.line),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 3,
                      children: [
                        Text(event.title, style: context.headline),
                        Text(
                          eventMeta(event.startsAt, event.location),
                          style: context.meta.copyWith(color: context.muted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: context.ink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      spacing: 6,
                      children: [
                        const Icon(
                          LucideIcons.ticket,
                          size: 15,
                          color: Colors.white,
                        ),
                        Text(
                          '${booking.quantity}',
                          style: context.metaStrong.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.booking, this.faded = false});

  final Booking booking;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final event = booking.event!;
    final venue = event.location.split(',').first.trim();

    return Opacity(
      opacity: faded ? 0.6 : 1,
      child: Material(
        color: context.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(AppRoutes.ticketDetail(booking.id)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              spacing: 14,
              children: [
                Container(
                  width: 52,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEEEA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM').format(event.startsAt).toUpperCase(),
                        style: context.dateBadgeMonth.copyWith(
                          color: context.accent,
                        ),
                      ),
                      Text(
                        DateFormat('dd').format(event.startsAt),
                        style: context.title.copyWith(height: 1.1),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      Text(
                        event.title,
                        style: context.bodyStrong,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${DateFormat('E').format(event.startsAt)} · '
                        '${DateFormat.jm().format(event.startsAt)} · $venue',
                        style: context.meta.copyWith(color: context.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          spacing: 4,
                          children: [
                            const Icon(
                              LucideIcons.ticket,
                              size: 13,
                              color: Color(0xFF3F434A),
                            ),
                            Text(
                              _countLabel(booking.quantity),
                              style: context.caption.copyWith(
                                color: const Color(0xFF3F434A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevronRight, size: 18, color: context.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
