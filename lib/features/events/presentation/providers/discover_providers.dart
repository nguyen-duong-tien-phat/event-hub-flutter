import 'package:event_hub_mobile/core/network/paginated_response.dart';
import 'package:event_hub_mobile/features/events/data/event_repository.dart';
import 'package:event_hub_mobile/features/events/data/models/event_filters.dart';
import 'package:event_hub_mobile/features/events/data/models/event_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discover_providers.g.dart';

/// The filters chosen on Discover. Search uses them too, so what you narrowed
/// down stays narrowed down when you start typing.
@Riverpod(keepAlive: true)
class DiscoverFilters extends _$DiscoverFilters {
  @override
  EventFilters build() => const EventFilters();

  void set(EventFilters filters) => state = filters;

  void reset() => state = const EventFilters();
}

/// Events matching [filters] and the text [query], soonest first.
@riverpod
Future<PaginatedResponse<EventSummary>> eventResults(
  Ref ref,
  EventFilters filters,
  String query,
) {
  final range = filters.dateRange(DateTime.now());

  return ref
      .watch(eventRepositoryProvider)
      .getEvents(
        pageSize: 50,
        from: range.from,
        to: range.to,
        search: query.trim(),
        category: filters.category,
        minPrice: filters.price?.min,
        maxPrice: filters.price?.max,
      );
}
