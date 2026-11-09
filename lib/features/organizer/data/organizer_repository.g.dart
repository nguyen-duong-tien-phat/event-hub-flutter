// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organizer_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(organizerRepository)
final organizerRepositoryProvider = OrganizerRepositoryProvider._();

final class OrganizerRepositoryProvider
    extends
        $FunctionalProvider<
          OrganizerRepository,
          OrganizerRepository,
          OrganizerRepository
        >
    with $Provider<OrganizerRepository> {
  OrganizerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'organizerRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$organizerRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrganizerRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OrganizerRepository create(Ref ref) {
    return organizerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrganizerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrganizerRepository>(value),
    );
  }
}

String _$organizerRepositoryHash() =>
    r'5a0f60eaee6171673623bf9bc1bca2f758f56586';
