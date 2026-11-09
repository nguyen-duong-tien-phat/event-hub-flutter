import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/utils/money.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/message_state.dart';
import 'package:event_hub_mobile/core/widgets/skeleton.dart';
import 'package:event_hub_mobile/core/widgets/skeleton_pulse.dart';
import 'package:event_hub_mobile/features/events/data/models/event.dart';
import 'package:event_hub_mobile/features/events/presentation/providers/events_provider.dart';
import 'package:event_hub_mobile/features/organizer/data/models/event_stats.dart';
import 'package:event_hub_mobile/features/organizer/presentation/providers/organizer_providers.dart';
import 'package:event_hub_mobile/features/organizer/presentation/widgets/organizer_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// One of the organizer's events: how it is selling, and the way to its
/// guest list, the check-in and the attendee's view of the event.
class OrganizerEventScreen extends ConsumerWidget {
  const OrganizerEventScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventDetailProvider(id));
    final stats = ref.watch(organizerEventStatsProvider(id));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            OrgTopBar(
              title: 'Event',
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.orgEvents),
              trailing: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.orgPreview(id)),
                icon: const Icon(LucideIcons.eye, size: 16),
                label: Text('Preview', style: context.metaStrong),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.ink,
                  side: BorderSide(color: context.line),
                  backgroundColor: context.surface,
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(organizerEventStatsProvider(id));
                  ref.invalidate(eventDetailProvider(id));
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    event.when(
                      loading: () => const _HeaderSkeleton(),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (event) => _Header(event: event),
                    ),
                    const SizedBox(height: 16),
                    ...stats.when(
                      loading: () => const [
                        SkeletonPulse(child: Skeleton(height: 300, radius: 16)),
                      ],
                      error: (_, _) => [
                        SizedBox(
                          height: 320,
                          child: MessageState(
                            icon: LucideIcons.wifiOff,
                            title: 'Couldn’t load the numbers',
                            message: 'Check your connection and try again.',
                            action: AppButton(
                              label: 'Try again',
                              onPressed: () => ref.invalidate(
                                organizerEventStatsProvider(id),
                              ),
                            ),
                          ),
                        ),
                      ],
                      data: (stats) => _stats(context, stats),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(eventId: id),
    );
  }

  List<Widget> _stats(BuildContext context, EventStats stats) {
    return [
      Row(
        spacing: 10,
        children: [
          Expanded(
            child: StatCard(
              label: 'Sold',
              value: '${stats.ticketsSold}',
              icon: LucideIcons.ticket,
            ),
          ),
          Expanded(
            child: StatCard(
              label: 'Held',
              value: '${stats.held}',
              hint: 'unpaid',
              icon: LucideIcons.clock,
              tint: OrgColors.warningSoft,
              iconColor: OrgColors.warning,
            ),
          ),
          Expanded(
            child: StatCard(
              label: 'In',
              value: '${stats.checkedIn}',
              icon: LucideIcons.circleCheck,
              tint: OrgColors.successSoft,
              iconColor: context.success,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        spacing: 10,
        children: [
          Expanded(
            child: StatCard(
              label: 'Revenue',
              value: formatMoney(stats.ticketRevenue),
              hint: 'without fees',
              icon: LucideIcons.dollarSign,
              tint: OrgColors.successSoft,
              iconColor: context.success,
            ),
          ),
          Expanded(
            child: StatCard(
              label: 'Bookings',
              value: '${stats.confirmed}',
              hint: '${stats.pending} pending · ${stats.cancelled} cancelled',
              icon: LucideIcons.clipboardList,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Text('TICKETS', style: context.overline.copyWith(color: context.muted)),
      const SizedBox(height: 10),
      RowsCard(
        children: [for (final t in stats.tickets) _TicketRow(ticket: t)],
      ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('E d MMM · h:mm a').format(event.startsAt);
    return Row(
      spacing: 14,
      children: [
        PosterImage(event.imageUrl, width: 76, height: 76, radius: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 3,
            children: [
              Text(
                date.toUpperCase(),
                style: context.dateLine.copyWith(color: context.accent),
              ),
              Text(event.title, style: context.cardTitle),
              Row(
                spacing: 6,
                children: [
                  Icon(LucideIcons.mapPin, size: 14, color: context.muted),
                  Expanded(
                    child: Text(
                      event.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.meta.copyWith(color: context.muted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonPulse(
      child: Row(
        spacing: 14,
        children: [
          Skeleton(width: 76, height: 76, radius: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Skeleton(width: 120, height: 12),
                Skeleton(height: 18),
                Skeleton(width: 160, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.ticket});

  final TicketStats ticket;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ticket.type, style: context.bodyStrong),
              Text(
                formatPrice(ticket.price),
                style: context.meta.copyWith(color: context.muted),
              ),
            ],
          ),
          ProgressBar(ticket.soldFraction),
          Text(
            '${ticket.sold} sold · ${ticket.remainingQuantity} left of ${ticket.totalQuantity}',
            style: context.caption.copyWith(color: context.muted),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(top: BorderSide(color: context.line)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            spacing: 10,
            children: [
              AppButton.icon(
                icon: LucideIcons.users,
                tooltip: 'Attendees',
                size: AppButtonSize.large,
                onPressed: () => context.push(AppRoutes.orgAttendees(eventId)),
              ),
              Expanded(
                child: AppButton(
                  label: 'Check in guests',
                  icon: LucideIcons.scanLine,
                  variant: AppButtonVariant.dark,
                  size: AppButtonSize.large,
                  expand: true,
                  onPressed: () => context.go(AppRoutes.orgCheckIn),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
