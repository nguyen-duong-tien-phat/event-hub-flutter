// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// True once the Splash has played its last hop and the reveal transition.
/// The router stays on the Splash until this is true, even if auth is
/// already known.

@ProviderFor(SplashDone)
final splashDoneProvider = SplashDoneProvider._();

/// True once the Splash has played its last hop and the reveal transition.
/// The router stays on the Splash until this is true, even if auth is
/// already known.
final class SplashDoneProvider extends $NotifierProvider<SplashDone, bool> {
  /// True once the Splash has played its last hop and the reveal transition.
  /// The router stays on the Splash until this is true, even if auth is
  /// already known.
  SplashDoneProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splashDoneProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splashDoneHash();

  @$internal
  @override
  SplashDone create() => SplashDone();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$splashDoneHash() => r'd9da786651862e6d9a21cc9f95735e34045c7192';

/// True once the Splash has played its last hop and the reveal transition.
/// The router stays on the Splash until this is true, even if auth is
/// already known.

abstract class _$SplashDone extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
