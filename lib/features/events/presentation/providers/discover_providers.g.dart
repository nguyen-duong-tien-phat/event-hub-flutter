// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The filters chosen on Discover. Search uses them too, so what you narrowed
/// down stays narrowed down when you start typing.

@ProviderFor(DiscoverFilters)
final discoverFiltersProvider = DiscoverFiltersProvider._();

/// The filters chosen on Discover. Search uses them too, so what you narrowed
/// down stays narrowed down when you start typing.
final class DiscoverFiltersProvider
    extends $NotifierProvider<DiscoverFilters, EventFilters> {
  /// The filters chosen on Discover. Search uses them too, so what you narrowed
  /// down stays narrowed down when you start typing.
  DiscoverFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoverFiltersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoverFiltersHash();

  @$internal
  @override
  DiscoverFilters create() => DiscoverFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventFilters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventFilters>(value),
    );
  }
}

String _$discoverFiltersHash() => r'84b890b2f32b52cb53a0c06df60805ff1442aca0';

/// The filters chosen on Discover. Search uses them too, so what you narrowed
/// down stays narrowed down when you start typing.

abstract class _$DiscoverFilters extends $Notifier<EventFilters> {
  EventFilters build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<EventFilters, EventFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EventFilters, EventFilters>,
              EventFilters,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The categories to filter by, as the backend stores them.

@ProviderFor(eventCategories)
final eventCategoriesProvider = EventCategoriesProvider._();

/// The categories to filter by, as the backend stores them.

final class EventCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// The categories to filter by, as the backend stores them.
  EventCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return eventCategories(ref);
  }
}

String _$eventCategoriesHash() => r'46347c79383963c89a3c507ac3078d2a0a375921';

/// Events matching [filters] and the text [query], soonest first. Starts with
/// the first page; [loadMore] adds the next ones to the end.

@ProviderFor(EventResults)
final eventResultsProvider = EventResultsFamily._();

/// Events matching [filters] and the text [query], soonest first. Starts with
/// the first page; [loadMore] adds the next ones to the end.
final class EventResultsProvider
    extends $AsyncNotifierProvider<EventResults, PagedState<EventSummary>> {
  /// Events matching [filters] and the text [query], soonest first. Starts with
  /// the first page; [loadMore] adds the next ones to the end.
  EventResultsProvider._({
    required EventResultsFamily super.from,
    required (EventFilters, String) super.argument,
  }) : super(
         retry: null,
         name: r'eventResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventResultsHash();

  @override
  String toString() {
    return r'eventResultsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  EventResults create() => EventResults();

  @override
  bool operator ==(Object other) {
    return other is EventResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventResultsHash() => r'34741889e0836955624764cb8ae6f600f9dcbe40';

/// Events matching [filters] and the text [query], soonest first. Starts with
/// the first page; [loadMore] adds the next ones to the end.

final class EventResultsFamily extends $Family
    with
        $ClassFamilyOverride<
          EventResults,
          AsyncValue<PagedState<EventSummary>>,
          PagedState<EventSummary>,
          FutureOr<PagedState<EventSummary>>,
          (EventFilters, String)
        > {
  EventResultsFamily._()
    : super(
        retry: null,
        name: r'eventResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Events matching [filters] and the text [query], soonest first. Starts with
  /// the first page; [loadMore] adds the next ones to the end.

  EventResultsProvider call(EventFilters filters, String query) =>
      EventResultsProvider._(argument: (filters, query), from: this);

  @override
  String toString() => r'eventResultsProvider';
}

/// Events matching [filters] and the text [query], soonest first. Starts with
/// the first page; [loadMore] adds the next ones to the end.

abstract class _$EventResults extends $AsyncNotifier<PagedState<EventSummary>> {
  late final _$args = ref.$arg as (EventFilters, String);
  EventFilters get filters => _$args.$1;
  String get query => _$args.$2;

  FutureOr<PagedState<EventSummary>> build(EventFilters filters, String query);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PagedState<EventSummary>>,
              PagedState<EventSummary>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PagedState<EventSummary>>,
                PagedState<EventSummary>
              >,
              AsyncValue<PagedState<EventSummary>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
