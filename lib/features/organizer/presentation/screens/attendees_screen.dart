import 'dart:async';

import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/load_more_footer.dart';
import 'package:event_hub_mobile/core/widgets/message_state.dart';
import 'package:event_hub_mobile/core/widgets/near_end_listener.dart';
import 'package:event_hub_mobile/core/widgets/skeleton.dart';
import 'package:event_hub_mobile/core/widgets/skeleton_pulse.dart';
import 'package:event_hub_mobile/features/bookings/presentation/widgets/booking_widgets.dart';
import 'package:event_hub_mobile/features/events/presentation/providers/events_provider.dart';
import 'package:event_hub_mobile/features/organizer/data/models/event_admission.dart';
import 'package:event_hub_mobile/features/organizer/presentation/providers/organizer_providers.dart';
import 'package:event_hub_mobile/features/organizer/presentation/widgets/organizer_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum _Filter { all, checkedIn, notYet }

/// Who holds a ticket to an event and whether they got in.
class AttendeesScreen extends ConsumerStatefulWidget {
  const AttendeesScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<AttendeesScreen> createState() => _AttendeesScreenState();
}

class _AttendeesScreenState extends ConsumerState<AttendeesScreen> {
  _Filter _filter = _Filter.all;
  String _search = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  bool? get _checkedIn => switch (_filter) {
    _Filter.all => null,
    _Filter.checkedIn => true,
    _Filter.notYet => false,
  };

  void _onSearch(String text) {
    // Wait for a pause in typing so each letter is not a request.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _search = text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.eventId;
    final title = ref.watch(eventDetailProvider(id)).value?.title;
    final stats = ref.watch(organizerEventStatsProvider(id)).value;
    final provider = eventAttendeesProvider(id, _checkedIn, _search);
    final attendees = ref.watch(provider);

    String count(int? n) => n == null ? '' : ' $n';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            OrgTopBar(
              title: 'Attendees',
              subtitle: title,
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.orgEvent(id)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TextField(
                onChanged: _onSearch,
                textInputAction: TextInputAction.search,
                style: context.body,
                decoration: InputDecoration(
                  hintText: 'Name, email or ticket code',
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 8,
                  children: [
                    FilterChipButton(
                      label: 'All${count(stats?.ticketsSold)}',
                      selected: _filter == _Filter.all,
                      onTap: () => setState(() => _filter = _Filter.all),
                    ),
                    FilterChipButton(
                      label: 'Checked in${count(stats?.checkedIn)}',
                      selected: _filter == _Filter.checkedIn,
                      onTap: () => setState(() => _filter = _Filter.checkedIn),
                    ),
                    FilterChipButton(
                      label:
                          'Not yet${count(stats == null ? null : stats.ticketsSold - stats.checkedIn)}',
                      selected: _filter == _Filter.notYet,
                      onTap: () => setState(() => _filter = _Filter.notYet),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: attendees.when(
                loading: () => const _ListSkeleton(),
                error: (_, _) => MessageState(
                  icon: LucideIcons.wifiOff,
                  title: 'Couldn’t load the guests',
                  message: 'Check your connection and try again.',
                  action: AppButton(
                    label: 'Try again',
                    onPressed: () => ref.invalidate(provider),
                  ),
                ),
                data: (page) {
                  if (page.items.isEmpty) {
                    return MessageState(
                      icon: LucideIcons.users,
                      title: _search.isEmpty
                          ? 'No guests here yet'
                          : 'No one matches “$_search”',
                      message: _search.isEmpty
                          ? 'People who buy a ticket show up here.'
                          : 'Try a name, an email or part of the ticket code.',
                      action: const SizedBox.shrink(),
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
                              for (final a in page.items) _AttendeeRow(a),
                            ],
                          ),
                          LoadMoreFooter(
                            isLoading: page.isLoadingMore,
                            hasError: page.loadMoreError != null,
                            onRetry: () =>
                                ref.read(provider.notifier).loadMore(),
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
      ),
    );
  }
}

class _AttendeeRow extends StatelessWidget {
  const _AttendeeRow(this.attendee);

  final EventAdmission attendee;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        spacing: 12,
        children: [
          InitialsAvatar(attendee.buyerName),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  attendee.buyerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyStrong,
                ),
                Text.rich(
                  TextSpan(
                    text: '${attendee.ticketType} · ',
                    children: [
                      TextSpan(
                        text: attendee.codeLabel,
                        style: const TextStyle(fontFamily: 'Menlo'),
                      ),
                    ],
                  ),
                  style: context.meta.copyWith(color: context.muted),
                ),
              ],
            ),
          ),
          attendee.checkedIn
              ? Pill('In · ${attendee.checkedInTime}', kind: PillKind.success)
              : const Pill('Not yet', kind: PillKind.neutral),
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
            Skeleton(height: 56, radius: 12),
            Skeleton(height: 56, radius: 12),
            Skeleton(height: 56, radius: 12),
            Skeleton(height: 56, radius: 12),
          ],
        ),
      ),
    );
  }
}
