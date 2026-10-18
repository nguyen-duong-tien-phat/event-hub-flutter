class Env {
  /// Set with `--dart-define-from-file=env/dev.json` (see the Makefile).
  /// The default is the local backend, which works on the iOS simulator; a
  /// physical device needs your computer's LAN IP instead of localhost.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
