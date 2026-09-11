import 'package:event_hub_mobile/core/network/base_repository.dart';
import 'package:event_hub_mobile/features/events/data/models/event.dart';

class EventRepository extends BaseRepository {
  EventRepository({super.apiClient});

  Future<List<Event>> getEvents({int page = 1, int size = 10}) async {
    return handleRequest(() async {
      final response = await apiClient.dio.get(
        '/events',
        queryParameters: {'page': page, 'pageSize': size},
      );

      final items = response.data['items'] as List<dynamic>;

      return items
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Event> getEventDetail(String id) {
    return handleRequest(() async {
      final response = await apiClient.dio.get('events/$id');
      return Event.fromJson(response.data);
    });
  }
}
