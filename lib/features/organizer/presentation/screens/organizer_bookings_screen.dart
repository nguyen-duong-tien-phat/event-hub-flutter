import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/utils/money.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/load_more_footer.dart';
import 'package:event_hub_mobile/core/widgets/message_state.dart';
import 'package:event_hub_mobile/core/widgets/near_end_listener.dart';
import 'package:event_hub_mobile/core/widgets/skeleton.dart';
import 'package:event_hub_mobile/core/widgets/skeleton_pulse.dart';
import 'package:event_hub_mobile/features/auth/data/models/user.dart';
import 'package:event_hub_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:event_hub_mobile/features/organizer/data/models/managed_booking.dart';
import 'package:event_hub_mobile/features/organizer/data/models/sales.dart';
import 'package:event_hub_mobile/features/organizer/presentation/providers/organizer_providers.dart';
import 'package:event_hub_mobile/features/organizer/presentation/widgets/organizer_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bookings on the organizer's events, newest first. Read only: a booking is
/// cancelled from the web dashboard.
class OrganizerBookingsScreen extends ConsumerStatefulWidget {
  const OrganizerBookingsScreen({super.key});

  @override
  ConsumerState<OrganizerBookingsScreen> createState() =>
      _OrganizerBookingsScreenState();
}

class _OrganizerBookingsScreenState
    extends ConsumerState<OrganizerBookingsScreen> {
  String? _eventId;
  String _eventTitle = 'All my events';

  /// null is "All"; otherwise the status name the API expects.
  String? _status;

  Future<void> _pickEvent() async {
    final sales = await ref.read(organizerSalesProvider.future);
    if (!mounted) return;
    final picked = await showModalBottomSheet<(String?, String)>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.surface,
      builder: (context) =>
          _EventPickerSheet(events: sales.events, selectedId: _eventId),
    );
    if (picked != null) {
      setState(() {
        _eventId = picked.$1;
        _eventTitle = picked.$2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authProvider).value?.role;
    final provider = organizerBookingsProvider(_eventId, _status);
    final bookings = ref.watch(provider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bookings', style: context.display),
                if (role != null)
                  Pill(role == UserRole.admin ? 'Admin' : 'Organizer'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: InkWell(
              onTap: _pickEvent,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.line),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _eventTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.control,
                      ),
                    ),
                    const Icon(LucideIcons.chevronDown, size: 18),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8,
                children: [
                  for (final (label, value) in const <(String, String?)>[
                    ('All', null),
                    ('Confirmed', 'Confirmed'),
                    ('Pending', 'Pending'),
                    ('Cancelled', 'Cancelled'),
                  ])
                    FilterChipButton(
                      label: label,
                      selected: _status == value,
                      onTap: () => setState(() => _status = value),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: bookings.when(
              loading: () => const _ListSkeleton(),
              error: (_, _) => MessageState(
                icon: LucideIcons.wifiOff,
                title: 'Couldn’t load the bookings',
                message: 'Check your connection and try again.',
                action: AppButton(
                  label: 'Try again',
                  onPressed: () => ref.invalidate(provider),
                ),
              ),
              data: (page) {
                if (page.items.isEmpty) {
                  return const MessageState(
                    icon: LucideIcons.clipboardList,
                    title: 'No bookings here',
                    message: 'Bookings on your events show up here.',
                    action: SizedBox.shrink(),
                  );
                }
                return NearEndListener(
                  onNearEnd: page.loadMoreError == null
                      ? () => ref.read(provider.notifier).loadMore()
                      : null,
                  child: RefreshIndicator(
                    onRefresh: () async => ref.invalidate(provider),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                      children: [
                        RowsCard(
                          children: [
                            for (final b in page.items) _BookingRow(b),
                          ],
                        ),
                        LoadMoreFooter(
                          isLoading: page.isLoadingMore,
                          hasError: page.loadMoreError != null,
                          onRetry: () => ref.read(provider.notifier).loadMore(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow(this.booking);

  final ManagedBooking booking;

  @override
  Widget build(BuildContext context) {
    final (label, kind) = switch (booking.status) {
      ManagedBookingStatus.confirmed => ('Confirmed', PillKind.success),
      ManagedBookingStatus.pending => ('Pending', PillKind.warning),
      ManagedBookingStatus.cancelled => ('Cancelled', PillKind.neutral),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        spacing: 12,
        children: [
          PosterImage(booking.eventImageUrl, width: 48, height: 48, radius: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(booking.buyerName, style: context.bodyStrong),
                Text(
                  '${booking.itemsLabel} · ${booking.eventTitle}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.meta.copyWith(color: context.muted),
                ),
                Text(
                  booking.whenLabel,
                  style: context.caption.copyWith(color: context.muted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 6,
            children: [
              Text(formatMoney(booking.totalPrice), style: context.bodyStrong),
              Pill(label, kind: kind),
            ],
          ),
        ],
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: SkeletonPulse(
        child: Column(
          spacing: 12,
          children: [
            Skeleton(height: 72, radius: 12),
            Skeleton(height: 72, radius: 12),
            Skeleton(height: 72, radius: 12),
          ],
        ),
      ),
    );
  }
}

/// The list of events to filter the bookings by, with a search field on top.
class _EventPickerSheet extends StatefulWidget {
  const _EventPickerSheet({required this.events, required this.selectedId});

  final List<EventSales> events;
  final String? selectedId;

  @override
  State<_EventPickerSheet> createState() => _EventPickerSheetState();
}

class _EventPickerSheetState extends State<_EventPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final events = [
      for (final e in widget.events)
        if (query.isEmpty ||
            e.title.toLowerCase().contains(query) ||
            e.location.toLowerCase().contains(query))
          e,
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: TextField(
                  autofocus: true,
                  onChanged: (text) => setState(() => _query = text),
                  style: context.body,
                  decoration: InputDecoration(
                    hintText: 'Search your events',
                    prefixIcon: const Icon(LucideIcons.search, size: 18),
                    filled: true,
                    fillColor: context.background,
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
              ),
              Expanded(
                child: ListView(
                  children: [
                    if (query.isEmpty)
                      ListTile(
                        title: const Text('All my events'),
                        trailing: widget.selectedId == null
                            ? const Icon(LucideIcons.check)
                            : null,
                        onTap: () =>
                            Navigator.pop(context, (null, 'All my events')),
                      ),
                    for (final e in events)
                      ListTile(
                        title: Text(
                          e.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(e.when),
                        trailing: widget.selectedId == e.id
                            ? const Icon(LucideIcons.check)
                            : null,
                        onTap: () => Navigator.pop(context, (e.id, e.title)),
                      ),
                    if (events.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No event matches “${_query.trim()}”',
                          textAlign: TextAlign.center,
                          style: context.bodySmall.copyWith(
                            color: context.muted,
                          ),
                        ),
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
