import 'package:flutter/services.dart';
import 'package:event_hub_mobile/features/auth/data/models/organizer.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/features/events/data/models/event.dart';
import 'package:event_hub_mobile/features/events/presentation/widgets/event_detail/event_about.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const double _gutter = 20;

/// Rounded sheet with the event details, overlapping the photo.
class EventSheet extends StatelessWidget {
  const EventSheet({
    super.key,
    required this.event,
    required this.soldOut,
    required this.fewLeft,
  });

  final Event event;
  final bool soldOut;
  final bool fewLeft;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE, MMMM d').format(event.startsAt);
    final start = DateFormat.jm().format(event.startsAt);
    final endsAt = event.endsAt;
    final time = endsAt == null
        ? start
        : '$start – ${DateFormat.jm().format(endsAt)}';
    final category = event.category;
    final venue = _splitLocation(event.location);

    return Container(
      width: double.infinity,
      // Bottom padding keeps the last block clear of the fixed bottom bar.
      padding: const EdgeInsets.fromLTRB(_gutter, 24, _gutter, 120),
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              if (category.isNotEmpty && category != 'Other' ||
                  soldOut ||
                  fewLeft)
                Row(
                  spacing: 6,
                  children: [
                    if (category.isNotEmpty && category != 'Other')
                      _Badge(
                        category,
                        foreground: context.accent,
                        background: context.accent.withValues(alpha: 0.09),
                      ),
                    if (soldOut)
                      _Badge(
                        'Sold out',
                        foreground: context.danger,
                        background: context.danger.withValues(alpha: 0.1),
                      )
                    else if (fewLeft)
                      const _Badge(
                        'Few tickets left',
                        foreground: Color(0xFF9A5B00),
                        background: Color(0xFFFBF1E0),
                      ),
                  ],
                ),
              Text(event.title, style: context.display.copyWith(height: 1.15)),
            ],
          ),
          Column(
            spacing: 14,
            children: [
              _InfoRow(icon: LucideIcons.calendar, title: date, subtitle: time),
              _InfoRow(
                icon: LucideIcons.mapPin,
                title: venue.name,
                subtitle: venue.address,
              ),
            ],
          ),
          const _Divider(),
          _Host(organizer: event.organizer),
          const _Divider(),
          EventAbout(description: event.description),
          if (event.highlights.isNotEmpty) ...[
            const _Divider(),
            _Expect(highlights: event.highlights),
          ],
          if (event.doorsOpenAt != null ||
              event.ageRestriction != null ||
              event.refundPolicy != null) ...[
            const _Divider(),
            _GoodToKnow(event: event),
          ],
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, thickness: 1, color: context.line);
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, {required this.foreground, required this.background});

  final String text;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: context.badge.copyWith(color: foreground)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 14,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.surface,
            border: Border.all(color: context.line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF3F434A)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(title, style: context.bodyStrong),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: context.meta.copyWith(color: context.muted),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Host extends StatelessWidget {
  const _Host({required this.organizer});
  final Organizer organizer;

  /// "Northside Live" -> "NL", "Finn" -> "F".
  String get _initials {
    final parts = organizer.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    final last = parts.length > 1 ? parts.last[0] : '';
    return (parts.first[0] + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final email = organizer.email;

    return Row(
      spacing: 12,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.accent.withValues(alpha: 0.09),
          ),
          child: Text(
            _initials,
            style: context.link.copyWith(color: context.accent),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hosted by',
                style: context.caption.copyWith(color: context.muted),
              ),
              Text(organizer.fullName, style: context.bodyStrong),
            ],
          ),
        ),
        if (email != null && email.isNotEmpty)
          AppButton(
            label: 'Contact',
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.small,
            onPressed: () => _showContact(context, organizer.fullName, email),
          ),
      ],
    );
  }
}

/// Bottom sheet with the host's email and a button to copy it.
void _showContact(BuildContext context, String name, String email) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: context.surface,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_gutter, 4, _gutter, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text('Contact $name', style: context.title),
            Row(
              spacing: 12,
              children: [
                Icon(LucideIcons.mail, size: 20, color: context.muted),
                Expanded(child: SelectableText(email, style: context.body)),
              ],
            ),
            AppButton(
              label: 'Copy email',
              variant: AppButtonVariant.dark,
              expand: true,
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await Clipboard.setData(ClipboardData(text: email));
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Email copied')),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// "What to expect": the event's highlights as a checklist.
class _Expect extends StatelessWidget {
  const _Expect({required this.highlights});
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text('What to expect', style: context.headline),
        for (final item in highlights)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Icon(
                  LucideIcons.check,
                  size: 16,
                  color: context.success,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: context.body.copyWith(color: const Color(0xFF3F434A)),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// _Venue name and, when the location has one, its address.
typedef _Venue = ({String name, String? address});

/// The backend stores one string such as "The Fillmore, San Francisco".
/// Show the part before the first comma as the venue name and the rest as
/// its address.
_Venue _splitLocation(String location) {
  final comma = location.indexOf(',');
  if (comma < 0) return (name: location.trim(), address: null);
  return (
    name: location.substring(0, comma).trim(),
    address: location.substring(comma + 1).trim(),
  );
}

/// "Good to know": doors, age limit and refund policy, when the event has them.
class _GoodToKnow extends StatelessWidget {
  const _GoodToKnow({required this.event});
  final Event event;

  @override
  Widget build(BuildContext context) {
    final doors = event.doorsOpenAt;
    final rows = [
      if (doors != null)
        (LucideIcons.clock, 'Doors open', DateFormat.jm().format(doors)),
      if (event.ageRestriction != null)
        (LucideIcons.userRound, 'Age', event.ageRestriction!),
      if (event.refundPolicy != null)
        (LucideIcons.fileText, 'Refunds', event.refundPolicy!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text('Good to know', style: context.headline),
        for (final (icon, label, value) in rows)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Icon(icon, size: 18, color: const Color(0xFF3F434A)),
              Text(
                label,
                style: context.body.copyWith(color: const Color(0xFF3F434A)),
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: context.bodyStrong,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
