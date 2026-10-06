// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(featuredEvents)
final featuredEventsProvider = FeaturedEventsProvider._();

final class FeaturedEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventSummary>>,
          List<EventSummary>,
          FutureOr<List<EventSummary>>
        >
    with
        $FutureModifier<List<EventSummary>>,
        $FutureProvider<List<EventSummary>> {
  FeaturedEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featuredEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featuredEventsHash();

  @$internal
  @override
  $FutureProviderElement<List<EventSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EventSummary>> create(Ref ref) {
    return featuredEvents(ref);
  }
}

String _$featuredEventsHash() => r'089b3defcf5a1897dfe0e1a95cc9cebf627ecf50';

@ProviderFor(upcomingEvents)
final upcomingEventsProvider = UpcomingEventsProvider._();

final class UpcomingEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventSummary>>,
          List<EventSummary>,
          FutureOr<List<EventSummary>>
        >
    with
        $FutureModifier<List<EventSummary>>,
        $FutureProvider<List<EventSummary>> {
  UpcomingEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingEventsHash();

  @$internal
  @override
  $FutureProviderElement<List<EventSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EventSummary>> create(Ref ref) {
    return upcomingEvents(ref);
  }
}

String _$upcomingEventsHash() => r'dc9530eb7be4acaff4cfca7343d6cd462631f205';
