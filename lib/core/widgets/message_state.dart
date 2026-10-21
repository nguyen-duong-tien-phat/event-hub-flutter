import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// Centered message for empty and error states: a round icon, a title, a
/// short explanation and one [action] (usually an [AppButton]).
class MessageState extends StatelessWidget {
  const MessageState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    // Centered when there is room, scrollable when there is not (landscape,
    // small screens, large text), so the content never overflows.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              // The bottom padding lifts the block above the true center.
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEFEEEA),
                    ),
                    child: Icon(icon, size: 28, color: const Color(0xFF3F434A)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: context.title,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: context.bodySmall.copyWith(color: context.muted),
                    ),
                  ),
                  const SizedBox(height: 24),
                  action,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
