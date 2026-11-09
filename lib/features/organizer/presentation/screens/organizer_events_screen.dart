import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/utils/money.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/message_state.dart';
import 'package:event_hub_mobile/core/widgets/skeleton.dart';
import 'package:event_hub_mobile/core/widgets/skeleton_pulse.dart';
import 'package:event_hub_mobile/features/auth/data/models/user.dart';
import 'package:event_hub_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:event_hub_mobile/features/organizer/data/models/sales.dart';
import 'package:event_hub_mobile/features/organizer/presentation/providers/organizer_providers.dart';
import 'package:event_hub_mobile/features/organizer/presentation/widgets/organizer_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The organizer's first tab: totals over their events, then each event with
/// how well it is selling. Read only: events are made on the web dashboard.
class OrganizerEventsScreen extends ConsumerStatefulWidget {
  const OrganizerEventsScreen({super.key});

  @override
  ConsumerState<OrganizerEventsScreen> createState() =>
      _OrganizerEventsScreenState();
}

class _OrganizerEventsScreenState extends ConsumerState<OrganizerEventsScreen> {
  bool _showUpcoming = true;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final sales = ref.watch(organizerSalesProvider);
    final role = ref.watch(authProvider).value?.role;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(organizerSalesProvider);
          try {
            await ref.read(organizerSalesProvider.future);
          } catch (_) {
            // The screen shows the error itself.
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Events', style: context.display),
                if (role != null)
                  Pill(role == UserRole.admin ? 'Admin' : 'Organizer'),
              ],
            ),
            const SizedBox(height: 16),
            ...sales.when(
              loading: () => const [_EventsSkeleton()],
              error: (error, _) => [
                SizedBox(
                  height: 420,
                  child: MessageState(
                    icon: LucideIcons.wifiOff,
                    title: 'Couldn’t load your events',
                    message: 'Check your connection and try again.',
                    action: AppButton(
                      label: 'Try again',
                      onPressed: () => ref.invalidate(organizerSalesProvider),
                    ),
                  ),
                ),
              ],
              data: (data) => _content(context, data),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, Sales data) {
    final query = _query.trim().toLowerCase();
    final searching = query.isNotEmpty;
    // A search looks through every event, upcoming first; without one the
    // Upcoming / Past switch decides.
    final events = searching
        ? [
            for (final e in [...data.upcoming, ...data.past])
              if (e.title.toLowerCase().contains(query) ||
                  e.location.toLowerCase().contains(query))
                e,
          ]
        : (_showUpcoming ? data.upcoming : data.past);

    return [
      TextField(
        onChanged: (text) => setState(() => _query = text),
        textInputAction: TextInputAction.search,
        style: context.body,
        decoration: InputDecoration(
          hintText: 'Search your events',
          prefixIcon: const Icon(LucideIcons.search, size: 18),
          filled: true,
          fillColor: context.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.line),
          ),
        ),
      ),
      if (!searching) ...[
        const SizedBox(height: 12),
        _Segmented(
          upcoming: _showUpcoming,
          onChanged: (value) => setState(() => _showUpcoming = value),
        ),
      ],
      const SizedBox(height: 14),
      if (events.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Column(
            children: [
              Text(
                searching
                    ? 'No event matches “${_query.trim()}”'
                    : _showUpcoming
                    ? 'No upcoming events'
                    : 'No past events',
                textAlign: TextAlign.center,
                style: context.headline,
              ),
              const SizedBox(height: 6),
              Text(
                searching
                    ? 'Try part of the title or the venue.'
                    : 'Events made on the web dashboard show up here.',
                textAlign: TextAlign.center,
                style: context.bodySmall.copyWith(color: context.muted),
              ),
            ],
          ),
        )
      else
        for (final event in events) ...[
          _EventCard(event: event),
          const SizedBox(height: 10),
        ],
    ];
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.upcoming, required this.onChanged});

  final bool upcoming;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget option(String label, bool value) {
      final selected = upcoming == value;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () => onChanged(value),
          child: Container(
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? context.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x14171C1C),
                        blurRadius: 2,
                        offset: Offset(0, 1),
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
        color: OrgColors.neutralSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [option('Upcoming', true), option('Past', false)]),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final EventSales event;

  @override
  Widget build(BuildContext context) {
    // Compact on purpose: a few events fit on one screen without scrolling.
    return Material(
      color: context.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.orgEvent(event.id)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            spacing: 12,
            children: [
              PosterImage(event.imageUrl, width: 72, height: 72, radius: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.bodyStrong,
                          ),
                        ),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 16,
                          color: context.muted,
                        ),
                      ],
                    ),
                    Text(
                      '${event.month} ${event.day} · ${event.when}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.meta.copyWith(color: context.muted),
                    ),
                    ProgressBar(event.soldFraction),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${event.ticketsSold} / ${event.totalQuantity} sold',
                          style: context.metaStrong,
                        ),
                        Text(
                          '${formatMoney(event.ticketRevenue)} · ${event.checkedIn} in',
                          style: context.meta.copyWith(color: context.muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventsSkeleton extends StatelessWidget {
  const _EventsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonPulse(
      child: Column(
        spacing: 12,
        children: [
          Skeleton(height: 48, radius: 12),
          Skeleton(height: 36, radius: 12),
          Skeleton(height: 96, radius: 16),
          Skeleton(height: 96, radius: 16),
          Skeleton(height: 96, radius: 16),
        ],
      ),
    );
  }
}
