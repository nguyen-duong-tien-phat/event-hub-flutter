import 'package:flutter/widgets.dart';

/// Calls [onNearEnd] when the vertical list below it is scrolled close to the
/// bottom, or is too short to scroll at all (so the next page is fetched
/// without the user having to do anything).
///
/// Pass null to switch it off, e.g. after a failed load, so a failing request
/// is not repeated over and over; the retry button is the way to try again.
/// [onNearEnd] may be called many times in a row; the caller must ignore the
/// calls it does not need.
class NearEndListener extends StatelessWidget {
  const NearEndListener({
    super.key,
    required this.onNearEnd,
    required this.child,
    this.threshold = 300,
  });

  final VoidCallback? onNearEnd;

  /// How many pixels from the bottom counts as "near".
  final double threshold;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<Notification>(
      onNotification: (notification) {
        // Scrolling, or the list changing size (new items, a short list).
        final metrics = switch (notification) {
          ScrollNotification(:final metrics) => metrics,
          ScrollMetricsNotification(:final metrics) => metrics,
          _ => null,
        };
        if (metrics != null &&
            metrics.axis == Axis.vertical &&
            metrics.extentAfter < threshold) {
          // Deferred a moment: the notification can arrive while the screen is
          // being laid out, and the state must not change in the middle of it.
          final callback = onNearEnd;
          if (callback != null) Future.microtask(callback);
        }
        return false;
      },
      child: child,
    );
  }
}
