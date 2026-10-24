import 'package:event_hub_mobile/core/network/api_client.dart';
import 'package:event_hub_mobile/core/network/network_provider.dart';
import 'package:event_hub_mobile/features/events/data/models/event_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'saved_repository.g.dart';

class SavedRepository {
  SavedRepository(this._apiClient);

  final ApiClient _apiClient;

  /// The saved events, most recently saved first.
  Future<List<EventSummary>> events() {
    return _apiClient.get(
      '/saved-events',
      parser: (json) => (json as List)
          .map((e) => EventSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Just the ids, so lists can show which events are saved.
  Future<Set<String>> ids() {
    return _apiClient.get(
      '/saved-events/ids',
      parser: (json) => Set<String>.from(json as List),
    );
  }

  Future<void> save(String eventId) =>
      _apiClient.put('/saved-events/$eventId', parser: (_) {});

  Future<void> unsave(String eventId) =>
      _apiClient.delete('/saved-events/$eventId', parser: (_) {});
}

@Riverpod(keepAlive: true)
SavedRepository savedRepository(Ref ref) {
  return SavedRepository(ref.watch(apiClientProvider));
}
