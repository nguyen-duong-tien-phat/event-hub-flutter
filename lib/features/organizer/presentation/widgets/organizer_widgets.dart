import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// Colors the organizer screens use besides the app's own (the design's soft
/// tints for success, warning and danger).
abstract final class OrgColors {
  static const accentSoft = Color(0xFFF1ECFB);
  static const successSoft = Color(0xFFE8F4EC);
  static const warning = Color(0xFF9A5B00);
  static const warningSoft = Color(0xFFFBF1E0);
  static const dangerSoft = Color(0xFFFBECEA);
  static const neutralSoft = Color(0xFFEFEEEA);
  static const inkSoft = Color(0xFF3F434A);
}

enum PillKind { accent, success, warning, danger, neutral }

/// A small rounded label: "Organizer", "Confirmed", "In · 7:42 PM".
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.kind = PillKind.accent});

  final String text;
  final PillKind kind;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      PillKind.accent => (OrgColors.accentSoft, context.accent),
      PillKind.success => (OrgColors.successSoft, context.success),
      PillKind.warning => (OrgColors.warningSoft, OrgColors.warning),
      PillKind.danger => (OrgColors.dangerSoft, context.danger),
      PillKind.neutral => (OrgColors.neutralSoft, OrgColors.inkSoft),
    };
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: context.badge.copyWith(color: fg)),
    );
  }
}

/// An event's picture with a plain tile while it loads or when it is missing.
class PosterImage extends StatelessWidget {
  const PosterImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.radius = 0,
  });

  final String url;
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(color: context.line);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: url.isEmpty
            ? placeholder
            : Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : placeholder,
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      ),
    );
  }
}

/// A number with a label and an icon, on a white card.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.hint,
    this.tint = OrgColors.accentSoft,
    this.iconColor,
  });

  final String label;
  final String value;
  final String? hint;
  final IconData icon;
  final Color tint;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Row(
            spacing: 8,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 15, color: iconColor ?? context.accent),
              ),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.overline.copyWith(color: context.muted),
                ),
              ),
            ],
          ),
          Text(value, style: context.title),
          if (hint != null)
            Text(hint!, style: context.caption.copyWith(color: context.muted)),
        ],
      ),
    );
  }
}

/// Thin bar showing how much of something is used, from 0 to 1.
class ProgressBar extends StatelessWidget {
  const ProgressBar(this.fraction, {super.key});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: fraction.clamp(0, 1).toDouble(),
        minHeight: 6,
        backgroundColor: OrgColors.neutralSoft,
        valueColor: AlwaysStoppedAnimation(context.accent),
      ),
    );
  }
}

/// A pill-shaped filter button: dark when selected.
class FilterChipButton extends StatelessWidget {
  const FilterChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? context.ink : context.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? context.ink : context.line),
          ),
          child: Text(
            label,
            style: context.control.copyWith(
              color: selected ? Colors.white : OrgColors.inkSoft,
              fontWeight: selected ? FontWeight.w600 : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded box that holds a list of rows with hairlines between them.
class RowsCard extends StatelessWidget {
  const RowsCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.line),
      ),
      child: Column(
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: context.line),
            child,
          ],
        ],
      ),
    );
  }
}

/// Header of a screen pushed over the tabs: a round back button, a title and
/// an optional line under it, and any [trailing] widget.
class OrgTopBar extends StatelessWidget {
  const OrgTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onBack,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        spacing: 12,
        children: [
          Material(
            color: context.surface,
            shape: CircleBorder(side: BorderSide(color: context.line)),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onBack,
              child: Tooltip(
                message: 'Back',
                child: SizedBox.square(
                  dimension: 40,
                  child: Icon(Icons.chevron_left, size: 24, color: context.ink),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.subhead),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.meta.copyWith(color: context.muted),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
