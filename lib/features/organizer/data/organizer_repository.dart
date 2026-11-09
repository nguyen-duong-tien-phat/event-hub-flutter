import 'package:event_hub_mobile/core/network/api_client.dart';
import 'package:event_hub_mobile/core/network/network_provider.dart';
import 'package:event_hub_mobile/core/network/paginated_response.dart';
import 'package:event_hub_mobile/features/organizer/data/models/check_in_result.dart';
import 'package:event_hub_mobile/features/organizer/data/models/event_admission.dart';
import 'package:event_hub_mobile/features/organizer/data/models/event_stats.dart';
import 'package:event_hub_mobile/features/organizer/data/models/managed_booking.dart';
import 'package:event_hub_mobile/features/organizer/data/models/sales.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'organizer_repository.g.dart';

/// What an organizer (or admin) reads and does from the phone: follow sales
/// and check guests in. Nothing here creates or edits events.
class OrganizerRepository {
  OrganizerRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Totals and one line per event. shortcut: only the first [pageSize] events
  /// are loaded (the list is split into upcoming and past on the phone); page
  /// through `/events/sales` if one account ever has more.
  Future<Sales> sales({int pageSize = 50}) => _apiClient.get(
    '/events/sales',
    queryParameters: {'page': 1, 'pageSize': pageSize},
    parser: (json) => Sales.fromJson(json as Map<String, dynamic>),
  );

  Future<EventStats> stats(String eventId) => _apiClient.get(
    '/events/$eventId/stats',
    parser: (json) => EventStats.fromJson(json as Map<String, dynamic>),
  );

  /// Who holds a ticket to the event. [checkedIn] true: only those who got in,
  /// false: only those who did not, null: everyone.
  Future<PaginatedResponse<EventAdmission>> admissions(
    String eventId, {
    int page = 1,
    int pageSize = 20,
    bool? checkedIn,
    String? search,
  }) => _apiClient.get(
    '/events/$eventId/admissions',
    queryParameters: {
      'page': page,
      'pageSize': pageSize,
      'checkedIn': ?checkedIn,
      if (search != null && search.isNotEmpty) 'search': search,
    },
    parser: (json) => PaginatedResponse.fromJson(
      json as Map<String, dynamic>,
      EventAdmission.fromJson,
    ),
  );

  /// Bookings on the organizer's events, newest first. [status] is one of
  /// Pending, Confirmed, Cancelled.
  Future<PaginatedResponse<ManagedBooking>> bookings({
    int page = 1,
    int pageSize = 20,
    String? eventId,
    String? status,
  }) => _apiClient.get(
    '/bookings/managed',
    queryParameters: {
      'page': page,
      'pageSize': pageSize,
      'eventId': ?eventId,
      'status': ?status,
    },
    parser: (json) => PaginatedResponse.fromJson(
      json as Map<String, dynamic>,
      ManagedBooking.fromJson,
    ),
  );

  /// Lets one ticket in. [code] is the QR value or the short code typed by
  /// hand. The API answers 409 (already used, not paid), 403 (not your event)
  /// and 400 (not a ticket) with the same body shape as 200, and the answer
  /// is the data, so none of them is an error here.
  Future<CheckInResult> checkIn(String code) => _apiClient.post(
    '/checkin',
    data: {'code': code},
    acceptedStatuses: const {400, 403, 409},
    parser: (json) => json is Map<String, dynamic> && json['status'] != null
        ? CheckInResult.fromJson(json)
        : const CheckInResult(status: CheckInStatus.invalid),
  );
}

@Riverpod(keepAlive: true)
OrganizerRepository organizerRepository(Ref ref) {
  return OrganizerRepository(ref.watch(apiClientProvider));
}
