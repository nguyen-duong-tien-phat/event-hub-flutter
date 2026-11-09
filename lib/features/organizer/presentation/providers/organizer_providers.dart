import 'package:event_hub_mobile/core/network/paged_state.dart';
import 'package:event_hub_mobile/core/network/paginated_response.dart';
import 'package:event_hub_mobile/features/organizer/data/models/event_admission.dart';
import 'package:event_hub_mobile/features/organizer/data/models/event_stats.dart';
import 'package:event_hub_mobile/features/organizer/data/models/managed_booking.dart';
import 'package:event_hub_mobile/features/organizer/data/models/sales.dart';
import 'package:event_hub_mobile/features/organizer/data/organizer_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'organizer_providers.g.dart';

/// How many rows one request asks for.
const organizerPageSize = 20;

/// The Events tab: totals and one line per event.
@riverpod
Future<Sales> organizerSales(Ref ref) =>
    ref.watch(organizerRepositoryProvider).sales();

@riverpod
Future<EventStats> organizerEventStats(Ref ref, String eventId) =>
    ref.watch(organizerRepositoryProvider).stats(eventId);

/// Who holds a ticket to [eventId], one page at a time. [checkedIn] null means
/// everyone; [search] matches the guest's name, email or ticket code.
@riverpod
class EventAttendees extends _$EventAttendees {
  /// Counts rebuilds, so a page that arrives after a new search is thrown away.
  int _generation = 0;

  @override
  Future<PagedState<EventAdmission>> build(
    String eventId,
    bool? checkedIn,
    String search,
  ) async {
    _generation++;
    return PagedState.first(await _fetch(1));
  }

  Future<PaginatedResponse<EventAdmission>> _fetch(int page) => ref
      .read(organizerRepositoryProvider)
      .admissions(
        eventId,
        page: page,
        pageSize: organizerPageSize,
        checkedIn: checkedIn,
        search: search,
      );

  /// Loads the next page; also the retry after a failed one.
  Future<void> loadMore() async {
    final current = state.value;
    if (state.isLoading || current == null) return;
    if (!current.hasMore || current.isLoadingMore) return;

    final generation = _generation;
    state = AsyncData(current.loading());
    try {
      final response = await _fetch(current.nextPage);
      if (!ref.mounted || generation != _generation) return;
      state = AsyncData(current.appended(response, idOf: (a) => a.id));
    } catch (error) {
      if (!ref.mounted || generation != _generation) return;
      state = AsyncData(current.failed(error));
    }
  }
}

/// Bookings on the organizer's events, newest first, one page at a time.
/// [eventId] null means all of them; [status] is Pending, Confirmed or Cancelled.
@riverpod
class OrganizerBookings extends _$OrganizerBookings {
  int _generation = 0;

  @override
  Future<PagedState<ManagedBooking>> build(
    String? eventId,
    String? status,
  ) async {
    _generation++;
    return PagedState.first(await _fetch(1));
  }

  Future<PaginatedResponse<ManagedBooking>> _fetch(int page) => ref
      .read(organizerRepositoryProvider)
      .bookings(
        page: page,
        pageSize: organizerPageSize,
        eventId: eventId,
        status: status,
      );

  Future<void> loadMore() async {
    final current = state.value;
    if (state.isLoading || current == null) return;
    if (!current.hasMore || current.isLoadingMore) return;

    final generation = _generation;
    state = AsyncData(current.loading());
    try {
      final response = await _fetch(current.nextPage);
      if (!ref.mounted || generation != _generation) return;
      state = AsyncData(current.appended(response, idOf: (b) => b.id));
    } catch (error) {
      if (!ref.mounted || generation != _generation) return;
      state = AsyncData(current.failed(error));
    }
  }
}
