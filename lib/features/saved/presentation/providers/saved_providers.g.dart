// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ids of the events the signed-in user has saved. Drives every heart button.

@ProviderFor(SavedIds)
final savedIdsProvider = SavedIdsProvider._();

/// Ids of the events the signed-in user has saved. Drives every heart button.
final class SavedIdsProvider
    extends $AsyncNotifierProvider<SavedIds, Set<String>> {
  /// Ids of the events the signed-in user has saved. Drives every heart button.
  SavedIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedIdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedIdsHash();

  @$internal
  @override
  SavedIds create() => SavedIds();
}

String _$savedIdsHash() => r'c92af4d67edb69ed3713b8099f5b58bab4cd438b';

/// Ids of the events the signed-in user has saved. Drives every heart button.

abstract class _$SavedIds extends $AsyncNotifier<Set<String>> {
  FutureOr<Set<String>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<String>>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>>, Set<String>>,
              AsyncValue<Set<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The events shown on the Saved tab.

@ProviderFor(savedEvents)
final savedEventsProvider = SavedEventsProvider._();

/// The events shown on the Saved tab.

final class SavedEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventSummary>>,
          List<EventSummary>,
          FutureOr<List<EventSummary>>
        >
    with
        $FutureModifier<List<EventSummary>>,
        $FutureProvider<List<EventSummary>> {
  /// The events shown on the Saved tab.
  SavedEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedEventsHash();

  @$internal
  @override
  $FutureProviderElement<List<EventSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EventSummary>> create(Ref ref) {
    return savedEvents(ref);
  }
}

String _$savedEventsHash() => r'013e3fec1eefee98d8532122a4403f4fc0a86093';
