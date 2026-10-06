import 'package:event_hub_mobile/core/network/api_client.dart';
import 'package:event_hub_mobile/core/network/network_provider.dart';
import 'package:event_hub_mobile/core/network/paginated_response.dart';
import 'package:event_hub_mobile/features/events/data/models/event_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_repository.g.dart';

class EventRepository {
  EventRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<PaginatedResponse<EventSummary>> getEvents({
    int page = 1,
    int pageSize = 10,
    DateTime? from,
    DateTime? to,
    String? search,
  }) {
    return _apiClient.get(
      '/events',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
        if (search != null && search.isNotEmpty) 'search': search,
      },
      parser: (json) => PaginatedResponse.fromJson(
        json as Map<String, dynamic>,
        EventSummary.fromJson,
      ),
    );
  }

  Future<List<EventSummary>> getFeturedEvents(int limit) {
    return _apiClient.get(
      '/events/featured',
      queryParameters: {'limit': limit},
      parser: (json) => (json as List)
          .map((event) => EventSummary.fromJson(event as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<List<EventSummary>> getUpcomingEvents(int limit) {
    return _apiClient.get(
      '/events/upcoming',
      queryParameters: {'limit': limit},
      parser: (json) => (json as List)
          .map((event) => EventSummary.fromJson(event as Map<String, dynamic>))
          .toList(),
    );
  }
}

@Riverpod(keepAlive: true)
EventRepository eventRepository(Ref ref) {
  return EventRepository(ref.watch(apiClientProvider));
}
