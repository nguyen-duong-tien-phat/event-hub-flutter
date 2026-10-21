import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// "About this event" with the text clamped to a few lines until expanded.
class EventAbout extends StatefulWidget {
  const EventAbout({super.key, required this.description});
  final String description;

  @override
  State<EventAbout> createState() => _EventAboutState();
}

class _EventAboutState extends State<EventAbout> {
  static const _collapsedLines = 4;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = context.body.copyWith(
      color: const Color(0xFF3F434A),
      height: 1.6,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text('About this event', style: context.headline),
        // Measure whether the text needs clamping, so "Read more" only shows
        // for descriptions that are actually cut off.
        LayoutBuilder(
          builder: (context, constraints) {
            final painter = TextPainter(
              text: TextSpan(text: widget.description, style: bodyStyle),
              maxLines: _collapsedLines,
              textDirection: Directionality.of(context),
            )..layout(maxWidth: constraints.maxWidth);
            final overflows = painter.didExceedMaxLines;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(
                  widget.description,
                  style: bodyStyle,
                  maxLines: _expanded ? null : _collapsedLines,
                  overflow: _expanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
                if (overflows)
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      _expanded ? 'Show less' : 'Read more',
                      style: context.link.copyWith(color: context.ink),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
