import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_provider.g.dart';

/// True once the Splash has played its last hop and the reveal transition.
/// The router stays on the Splash until this is true, even if auth is
/// already known.
@Riverpod(keepAlive: true)
class SplashDone extends _$SplashDone {
  @override
  bool build() => false;

  void finish() => state = true;
}
