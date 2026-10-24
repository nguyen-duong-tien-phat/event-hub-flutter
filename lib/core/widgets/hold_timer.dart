import 'dart:async';

import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "Tickets held for you  9:41" banner counting down to [expiresAt].
/// Calls [onExpired] once when the time runs out.
class HoldTimer extends StatefulWidget {
  const HoldTimer({super.key, required this.expiresAt, this.onExpired});

  final DateTime expiresAt;
  final VoidCallback? onExpired;

  @override
  State<HoldTimer> createState() => _HoldTimerState();
}

class _HoldTimerState extends State<HoldTimer> {
  late final Timer _ticker;
  late Duration _left;
  bool _expiredReported = false;

  Duration get _remaining {
    final left = widget.expiresAt.toUtc().difference(DateTime.now().toUtc());
    return left.isNegative ? Duration.zero : left;
  }

  @override
  void initState() {
    super.initState();
    _left = _remaining;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    // The hold may already be over when the screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportIfExpired());
  }

  void _tick() {
    setState(() => _left = _remaining);
    _reportIfExpired();
  }

  void _reportIfExpired() {
    if (!mounted || _left > Duration.zero || _expiredReported) return;
    _expiredReported = true;
    widget.onExpired?.call();
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  String get _text {
    final minutes = _left.inMinutes;
    final seconds = (_left.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final expired = _left == Duration.zero;
    const textColor = Color(0xFF3F434A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEEEA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        spacing: 10,
        children: [
          const Icon(LucideIcons.clock, size: 16, color: textColor),
          Expanded(
            child: Text(
              expired ? 'Your hold has expired' : 'Tickets held for you',
              style: context.meta.copyWith(color: textColor),
            ),
          ),
          if (!expired)
            Text(
              _text,
              style: context.meta.copyWith(
                color: context.ink,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}
