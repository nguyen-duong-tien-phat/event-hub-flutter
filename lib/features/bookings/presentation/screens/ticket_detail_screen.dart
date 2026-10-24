import 'package:event_hub_mobile/core/network/api_exception.dart';
import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/app_header.dart';
import 'package:event_hub_mobile/core/widgets/message_state.dart';
import 'package:event_hub_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:event_hub_mobile/features/bookings/data/models/booking.dart';
import 'package:event_hub_mobile/features/bookings/presentation/providers/booking_providers.dart';
import 'package:event_hub_mobile/features/bookings/presentation/widgets/booking_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// One ticket of a booking, with the QR code to scan at the door. A booking of
/// several tickets is a row of pages to swipe through.
class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider(widget.bookingId));

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(title: 'Your ticket'),
          Expanded(
            child: booking.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => MessageState(
                icon: LucideIcons.wifiOff,
                title: 'Couldn’t load your ticket',
                message: error is ApiException
                    ? error.message
                    : 'Check your connection and try again.',
                action: AppButton(
                  label: 'Try again',
                  variant: AppButtonVariant.dark,
                  onPressed: () =>
                      ref.invalidate(bookingProvider(widget.bookingId)),
                ),
              ),
              data: _content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(Booking booking) {
    final event = booking.event;
    final holder = ref.watch(authProvider).value?.fullName ?? '';

    // "2 × General, 1 × VIP" becomes three tickets, numbered 1 to 3.
    final tickets = [
      for (final item in booking.tickets)
        for (var i = 0; i < item.quantity; i++) item.type,
    ];

    if (event == null || tickets.isEmpty) {
      return MessageState(
        icon: LucideIcons.ticket,
        title: 'Ticket not found',
        message: 'We couldn’t find the details of this ticket.',
        action: AppButton(
          label: 'Back to tickets',
          variant: AppButtonVariant.dark,
          onPressed: () => context.go(AppRoutes.tickets),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            itemCount: tickets.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                bookingGutter,
                12,
                bookingGutter,
                12,
              ),
              child: _TicketCard(
                booking: booking,
                event: event,
                type: tickets[index],
                number: index + 1,
                holder: holder,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                Text(
                  'Ticket ${_page + 1} of ${tickets.length}',
                  style: context.caption.copyWith(color: context.muted),
                ),
                if (tickets.length > 1)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6,
                    children: [
                      for (var i = 0; i < tickets.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: i == _page ? 14 : 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: i == _page ? context.ink : context.line,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.booking,
    required this.event,
    required this.type,
    required this.number,
    required this.holder,
  });

  final Booking booking;
  final BookingEvent event;
  final String type;
  final int number;
  final String holder;

  /// "EH-3F9A2C-01"
  String get _code =>
      '${booking.orderNumber}-${number.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final over = event.startsAt.toUtc().isBefore(DateTime.now().toUtc());
    final valid = booking.isConfirmed && !over;

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.line),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      type.toUpperCase(),
                      style: context.overline.copyWith(color: context.muted),
                    ),
                    _StatusBadge(booking: booking, over: over),
                  ],
                ),
                Text(event.title, style: context.title),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Wrap(
              runSpacing: 14,
              children: [
                _Fact('Date', DateFormat('E, MMM d').format(event.startsAt)),
                _Fact('Time', DateFormat.jm().format(event.startsAt)),
                _Fact('Venue', event.location.split(',').first.trim()),
                _Fact('Holder', holder.isEmpty ? '-' : holder),
              ],
            ),
          ),
          const TicketPerforation(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Center(
              child: Column(
                spacing: 14,
                children: [
                  Opacity(
                    opacity: valid ? 1 : 0.25,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: context.line),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: QrImageView(
                        data: 'eventhub:ticket:${booking.id}:$number',
                        size: 190,
                        padding: EdgeInsets.zero,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: context.ink,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: context.ink,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    _code,
                    style: context.bodyStrong.copyWith(letterSpacing: 1.2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.booking, required this.over});

  final Booking booking;
  final bool over;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (booking.status) {
      BookingStatus.cancelled => (
        'Cancelled',
        context.danger,
        context.danger.withValues(alpha: 0.1),
      ),
      BookingStatus.pending => (
        'Pending',
        const Color(0xFF9A5B00),
        const Color(0xFFFBF1E0),
      ),
      BookingStatus.confirmed when over => (
        'Used',
        const Color(0xFF3F434A),
        const Color(0xFFEFEEEA),
      ),
      BookingStatus.confirmed => (
        'Valid',
        context.success,
        const Color(0xFFE8F4EC),
      ),
    };

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: context.badge.copyWith(color: fg)),
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
