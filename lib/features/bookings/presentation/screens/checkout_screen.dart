import 'package:event_hub_mobile/core/network/api_exception.dart';
import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/utils/money.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/app_header.dart';
import 'package:event_hub_mobile/core/widgets/bottom_action_bar.dart';
import 'package:event_hub_mobile/core/widgets/hold_timer.dart';
import 'package:event_hub_mobile/core/widgets/message_state.dart';
import 'package:event_hub_mobile/core/widgets/skeleton.dart';
import 'package:event_hub_mobile/core/widgets/skeleton_pulse.dart';
import 'package:event_hub_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:event_hub_mobile/features/bookings/data/booking_repository.dart';
import 'package:event_hub_mobile/features/bookings/data/models/booking.dart';
import 'package:event_hub_mobile/features/bookings/presentation/providers/booking_providers.dart';
import 'package:event_hub_mobile/features/bookings/presentation/widgets/booking_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Order summary. The tickets are held while the user is here; leaving the
/// screen gives them back.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _expired = false;

  late final _repository = ref.read(bookingRepositoryProvider);

  void _onExpired() {
    if (_expired) return;
    setState(() => _expired = true);
    _repository.releaseIfPending(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider(widget.bookingId));

    return PopScope(
      // Any way out of this screen (back button, swipe) releases the tickets.
      // Going on to payment pushes a new screen, so it does not count.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _repository.releaseIfPending(widget.bookingId);
      },
      child: Scaffold(
        bottomNavigationBar: booking.value == null
            ? null
            : _bottomBar(context, booking.value!),
        body: Column(
          children: [
            const AppHeader(title: 'Order summary'),
            Expanded(
              child: booking.when(
                loading: () => const _Skeleton(),
                error: (error, _) => MessageState(
                  icon: LucideIcons.wifiOff,
                  title: 'Couldn’t load your order',
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
                data: (booking) => _content(context, booking),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(BuildContext context, Booking booking) {
    if (booking.isConfirmed) {
      // Free tickets are confirmed straight away: nothing to pay.
      return BottomActionBar(
        actionLabel: 'Get tickets',
        onPressed: () => context.go(AppRoutes.orderSuccess(booking.id)),
      );
    }

    final unavailable = _expired || !booking.isPending;
    return BottomActionBar(
      actionLabel: unavailable ? 'Choose tickets again' : 'Continue to payment',
      onPressed: unavailable
          ? () => context.go(AppRoutes.selectTickets(booking.eventId))
          : () => context.push(AppRoutes.payment(booking.id)),
    );
  }

  Widget _content(BuildContext context, Booking booking) {
    final user = ref.watch(authProvider).value;
    final event = booking.event;

    return ListView(
      padding: const EdgeInsets.fromLTRB(bookingGutter, 12, bookingGutter, 24),
      children: [
        if (booking.isPending)
          HoldTimer(expiresAt: booking.expiresAt, onExpired: _onExpired),
        if (!booking.isPending && !booking.isConfirmed)
          const _Notice(
            'This order was cancelled, so its tickets were released.',
          ),
        const SizedBox(height: 20),
        BookingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 14,
            children: [
              if (event != null)
                EventMiniCard(
                  imageUrl: event.imageUrl,
                  title: event.title,
                  meta: eventMeta(event.startsAt, event.location),
                ),
              Divider(height: 1, thickness: 1, color: context.line),
              for (final ticket in booking.tickets)
                PriceRow(
                  '${ticket.type} × ${ticket.quantity}',
                  formatPrice(ticket.total),
                ),
              const DashedDivider(),
              PriceBreakdown(booking: booking),
            ],
          ),
        ),
        if (user != null) ...[
          const SizedBox(height: 20),
          Text(
            'BOOKED BY',
            style: context.overline.copyWith(color: context.muted),
          ),
          const SizedBox(height: 10),
          BookingCard(
            padding: 14,
            child: Row(
              spacing: 12,
              children: [
                InitialsAvatar(user.fullName),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName, style: context.bodyStrong),
                      Text(
                        user.email,
                        style: context.meta.copyWith(color: context.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEEEA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: context.meta),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonPulse(
      child: Padding(
        padding: EdgeInsets.fromLTRB(bookingGutter, 12, bookingGutter, 24),
        child: Column(
          spacing: 20,
          children: [
            Skeleton(height: 44, radius: 12),
            Skeleton(height: 260, radius: 16),
            Skeleton(height: 72, radius: 16),
          ],
        ),
      ),
    );
  }
}
