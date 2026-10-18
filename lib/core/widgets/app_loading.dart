import 'dart:math' as math;

import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_icon.dart';
import 'package:flutter/material.dart';

/// Loading indicator built around [AppIcon]: the icon hops, spins one full
/// turn in the air, then lands with a small squash above a shadow.
///
/// Set [finishing] once the work is done: the hop in progress plays out to
/// its landing, the animation stops, and [onFinished] is called.
class AppLoading extends StatefulWidget {
  const AppLoading({
    super.key,
    this.size = 44,
    this.finishing = false,
    this.onFinished,
    this.iconKey,
  });

  /// Size of the icon.
  final double size;

  /// Lets the parent find where the icon is on screen (e.g. to grow a
  /// transition out of it).
  final GlobalKey? iconKey;

  /// When true, finish the current hop instead of looping again.
  final bool finishing;

  /// Called after the hop has landed, once [finishing] is true.
  final VoidCallback? onFinished;

  @override
  State<AppLoading> createState() => _AppLoadingState();
}

class _AppLoadingState extends State<AppLoading>
    with SingleTickerProviderStateMixin {
  /// Share of each cycle spent in the air. The rest is the landing + rest.
  static const double _airTime = 0.7;
  static const double _shadowHeight = 6;

  static const Duration _cycle = Duration(milliseconds: 1300);

  late final AnimationController _controller;
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _cycle)
      ..repeat();
    if (widget.finishing) _finish();
  }

  @override
  void didUpdateWidget(AppLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.finishing && !oldWidget.finishing) _finish();
  }

  /// Plays the rest of the current hop (value -> 1.0) and stops looping.
  void _finish() {
    if (_isFinishing) return;
    _isFinishing = true;

    final remaining = _cycle * (1 - _controller.value);
    _controller.animateTo(1, duration: remaining, curve: Curves.linear).then((
      _,
    ) {
      if (mounted) widget.onFinished?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final jumpHeight = size * 0.9;
    final ink = context.ink;

    return SizedBox(
      width: size * 1.6,
      height: size + jumpHeight + _shadowHeight + 8,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final inAir = t < _airTime;

          // 0 -> 1 over the jump, 0 on the ground.
          final air = inAir ? t / _airTime : 0.0;
          // 0 -> 1 -> 0 arc: peaks mid-jump.
          final arc = math.sin(math.pi * air);
          final lift = Curves.easeOut.transform(arc) * jumpHeight;
          final angle = Curves.easeInOut.transform(air) * 2 * math.pi;

          // Squash on landing: wider and shorter, then settle.
          final land = inAir ? 0.0 : (t - _airTime) / (1 - _airTime);
          final squash = math.sin(math.pi * land) * 0.14;

          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Shadow shrinks and fades as the icon rises.
              Container(
                width: size * 0.8 * (1 - 0.45 * arc),
                height: _shadowHeight,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(_shadowHeight),
                  color: ink.withValues(alpha: 0.16 * (1 - 0.6 * arc)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: _shadowHeight + 2),
                child: Transform.translate(
                  offset: Offset(0, -lift),
                  child: Transform.scale(
                    alignment: Alignment.bottomCenter,
                    scaleX: 1 + squash,
                    scaleY: 1 - squash,
                    child: Transform.rotate(
                      angle: angle,
                      child: SizedBox(
                        key: widget.iconKey,
                        width: size,
                        height: size,
                        child: const FittedBox(child: AppIcon()),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
