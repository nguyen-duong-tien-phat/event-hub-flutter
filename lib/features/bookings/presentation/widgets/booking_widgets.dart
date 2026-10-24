import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/utils/money.dart';
import 'package:event_hub_mobile/features/bookings/data/models/booking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Gutter shared by the booking screens.
const double bookingGutter = 20;

/// "Sat, Oct 14 · 7:00 PM · The Fillmore"
String eventMeta(DateTime startsAt, String location) {
  final venue = location.split(',').first.trim();
  return '${DateFormat('E, MMM d').format(startsAt)} · '
      '${DateFormat.jm().format(startsAt)} · $venue';
}

/// Small event thumbnail with its title and date line.
class EventMiniCard extends StatelessWidget {
  const EventMiniCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.meta,
  });

  final String imageUrl;
  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox.square(
            dimension: 48,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  ColoredBox(color: context.line),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.bodyStrong,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                meta,
                style: context.meta.copyWith(color: context.muted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// White rounded card used by the booking screens.
class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.child, this.padding = 18});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

/// One "label ........ amount" line.
class PriceRow extends StatelessWidget {
  const PriceRow(this.label, this.amount, {super.key, this.strong = false});

  final String label;
  final String amount;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final labelStyle = strong
        ? context.bodyStrong
        : context.bodySmall.copyWith(color: context.muted);
    final amountStyle = (strong ? context.bodyStrong : context.bodySmall)
        .copyWith(
          fontWeight: strong ? null : FontWeight.w500,
          fontFeatures: const [FontFeature.tabularFigures()],
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 16,
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        Text(amount, style: amountStyle),
      ],
    );
  }
}

/// Subtotal, service fee and total of a booking.
class PriceBreakdown extends StatelessWidget {
  const PriceBreakdown({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        PriceRow('Subtotal', formatMoney(booking.subtotal)),
        if (booking.serviceFee > 0)
          PriceRow('Service fee', formatMoney(booking.serviceFee)),
        PriceRow('Total', formatMoney(booking.totalPrice), strong: true),
      ],
    );
  }
}

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dash = 5.0;
        const gap = 4.0;
        final count = (constraints.maxWidth / (dash + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < count; i++)
              Container(width: dash, height: 1.5, color: context.line),
          ],
        );
      },
    );
  }
}

/// Avatar circle with the initials of [name].
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar(this.name, {super.key, this.size = 40});

  final String name;
  final double size;

  /// "Alex Lee" -> "AL", "Finn" -> "F".
  String get _initials {
    final parts = name
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
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.accent.withValues(alpha: 0.09),
      ),
      child: _initials.isEmpty
          ? Icon(
              LucideIcons.userRound,
              size: size * 0.45,
              color: context.accent,
            )
          : Text(
              _initials,
              style: context.link.copyWith(color: context.accent),
            ),
    );
  }
}

/// The dashed line with a notch on each side, like a torn ticket. Place it
/// between two parts of a card whose edges are clipped.
class TicketPerforation extends StatelessWidget {
  const TicketPerforation({super.key});

  @override
  Widget build(BuildContext context) {
    Widget notch() => Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.background,
      ),
    );

    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: DashedDivider(),
          ),
          Positioned(left: -12, child: notch()),
          Positioned(right: -12, child: notch()),
        ],
      ),
    );
  }
}
