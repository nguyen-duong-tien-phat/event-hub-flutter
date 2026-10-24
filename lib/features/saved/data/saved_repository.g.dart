// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(savedRepository)
final savedRepositoryProvider = SavedRepositoryProvider._();

final class SavedRepositoryProvider
    extends
        $FunctionalProvider<SavedRepository, SavedRepository, SavedRepository>
    with $Provider<SavedRepository> {
  SavedRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedRepositoryHash();

  @$internal
  @override
  $ProviderElement<SavedRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SavedRepository create(Ref ref) {
    return savedRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedRepository>(value),
    );
  }
}

String _$savedRepositoryHash() => r'a629b55e70a7c1b2c0b2509a37d499506265bd1a';
