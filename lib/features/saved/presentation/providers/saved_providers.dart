import 'package:event_hub_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:event_hub_mobile/features/events/data/models/event_summary.dart';
import 'package:event_hub_mobile/features/saved/data/saved_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'saved_providers.g.dart';

/// Ids of the events the signed-in user has saved. Drives every heart button.
@Riverpod(keepAlive: true)
class SavedIds extends _$SavedIds {
  @override
  Future<Set<String>> build() async {
    // Start over whenever someone signs in or out.
    final user = ref.watch(authProvider).value;
    if (user == null) return {};
    return ref.watch(savedRepositoryProvider).ids();
  }

  /// Saves or unsaves [eventId]. The heart flips right away; if the request
  /// fails it flips back and the error is rethrown.
  Future<void> toggle(String eventId) async {
    final before = state.value ?? {};
    final saving = !before.contains(eventId);
    final repository = ref.read(savedRepositoryProvider);

    state = AsyncData(
      saving ? {...before, eventId} : ({...before}..remove(eventId)),
    );

    try {
      if (saving) {
        await repository.save(eventId);
      } else {
        await repository.unsave(eventId);
      }
      ref.invalidate(savedEventsProvider);
    } catch (_) {
      state = AsyncData(before);
      rethrow;
    }
  }
}

/// The events shown on the Saved tab.
@riverpod
Future<List<EventSummary>> savedEvents(Ref ref) {
  final user = ref.watch(authProvider).value;
  if (user == null) return Future.value([]);
  return ref.watch(savedRepositoryProvider).events();
}
