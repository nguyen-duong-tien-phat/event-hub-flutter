import 'package:event_hub_mobile/core/network/api_exception.dart';
import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/utils/money.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/message_state.dart';
import 'package:event_hub_mobile/features/bookings/data/models/booking.dart';
import 'package:event_hub_mobile/features/bookings/presentation/providers/booking_providers.dart';
import 'package:event_hub_mobile/features/bookings/presentation/widgets/booking_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "You're going!" with a ticket-like summary of the order.
class OrderSuccessScreen extends ConsumerWidget {
  const OrderSuccessScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider(bookingId));

    return Scaffold(
      body: booking.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => MessageState(
          icon: LucideIcons.wifiOff,
          title: 'Couldn’t load your order',
          message: error is ApiException
              ? error.message
              : 'Check your connection and try again.',
          action: AppButton(
            label: 'Go home',
            variant: AppButtonVariant.dark,
            onPressed: () => context.go(AppRoutes.home),
          ),
        ),
        data: (booking) => _Content(booking: booking),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final event = booking.event;
    final confirmed = booking.isConfirmed;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: bookingGutter),
              children: [
                const SizedBox(height: 48),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE8F4EC),
                    ),
                    child: Icon(
                      LucideIcons.check,
                      size: 30,
                      color: context.success,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  confirmed ? 'You’re going!' : 'Payment received',
                  textAlign: TextAlign.center,
                  style: context.display,
                ),
                const SizedBox(height: 8),
                Text(
                  confirmed
                      ? 'Your tickets are ready in My tickets.'
                      : 'We’re confirming your tickets. They’ll show up in My '
                            'tickets in a moment.',
                  textAlign: TextAlign.center,
                  style: context.body.copyWith(color: context.muted),
                ),
                const SizedBox(height: 32),
                _OrderCard(booking: booking, event: event),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              bookingGutter,
              0,
              bookingGutter,
              20,
            ),
            child: Column(
              spacing: 10,
              children: [
                AppButton(
                  label: 'View tickets',
                  variant: AppButtonVariant.dark,
                  size: AppButtonSize.large,
                  expand: true,
                  onPressed: () => context.go(AppRoutes.tickets),
                ),
                AppButton(
                  label: 'Back to Discover',
                  variant: AppButtonVariant.ghost,
                  expand: true,
                  onPressed: () => context.go(AppRoutes.home),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.booking, required this.event});

  final Booking booking;
  final BookingEvent? event;

  @override
  Widget build(BuildContext context) {
    final startsAt = event?.startsAt;

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.line),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  'ORDER ${booking.orderNumber}',
                  style: context.overline.copyWith(color: context.muted),
                ),
                Text(event?.title ?? 'Your event', style: context.cardTitle),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Wrap(
              runSpacing: 14,
              children: [
                _Fact(
                  'Date',
                  startsAt == null
                      ? '-'
                      : DateFormat('E, MMM d').format(startsAt),
                ),
                _Fact(
                  'Time',
                  startsAt == null ? '-' : DateFormat.jm().format(startsAt),
                ),
                _Fact('Venue', event?.location.split(',').first.trim() ?? '-'),
                _Fact('Tickets', booking.ticketsSummary),
              ],
            ),
          ),
          const TicketPerforation(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.isConfirmed ? 'Total paid' : 'Total',
                  style: context.bodySmall.copyWith(color: context.muted),
                ),
                Text(
                  formatMoney(booking.totalPrice),
                  style: context.bodyStrong,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    // Two per row.
    final width =
        (MediaQuery.sizeOf(context).width - 2 * bookingGutter - 40) / 2;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(label, style: context.caption.copyWith(color: context.muted)),
          Text(value, style: context.link, maxLines: 2),
        ],
      ),
    );
  }
}
