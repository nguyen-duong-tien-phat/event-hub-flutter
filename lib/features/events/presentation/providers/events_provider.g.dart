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

String _$featuredEventsHash() => r'3f7715b6e776fb93a0365fe99ad39cf80f87553e';
