import 'package:event_hub_mobile/features/events/data/event_repository.dart';
import 'package:event_hub_mobile/features/events/data/models/event_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'events_provider.g.dart';

@riverpod
Future<List<EventSummary>> featuredEvents(Ref ref) async {
  final response = await ref.watch(eventRepositoryProvider).getFeturedEvents(5);

  return response;
}

@riverpod
Future<List<EventSummary>> upcomingEvents(Ref ref) async {
  final response = await ref
      .watch(eventRepositoryProvider)
      .getUpcomingEvents(5);

  return response;
}
