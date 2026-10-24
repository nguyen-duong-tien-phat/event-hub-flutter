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

/// Events matching [filters] and the text [query], soonest first.

@ProviderFor(eventResults)
final eventResultsProvider = EventResultsFamily._();

/// Events matching [filters] and the text [query], soonest first.

final class EventResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaginatedResponse<EventSummary>>,
          PaginatedResponse<EventSummary>,
          FutureOr<PaginatedResponse<EventSummary>>
        >
    with
        $FutureModifier<PaginatedResponse<EventSummary>>,
        $FutureProvider<PaginatedResponse<EventSummary>> {
  /// Events matching [filters] and the text [query], soonest first.
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
  $FutureProviderElement<PaginatedResponse<EventSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaginatedResponse<EventSummary>> create(Ref ref) {
    final argument = this.argument as (EventFilters, String);
    return eventResults(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is EventResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventResultsHash() => r'c57db155ee64f2bdd12ebb1f9b3362e6be856eed';

/// Events matching [filters] and the text [query], soonest first.

final class EventResultsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PaginatedResponse<EventSummary>>,
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

  /// Events matching [filters] and the text [query], soonest first.

  EventResultsProvider call(EventFilters filters, String query) =>
      EventResultsProvider._(argument: (filters, query), from: this);

  @override
  String toString() => r'eventResultsProvider';
}
