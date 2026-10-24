import 'package:event_hub_mobile/core/config/env.dart';
import 'package:event_hub_mobile/core/network/api_exception.dart';
import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/utils/money.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/app_header.dart';
import 'package:event_hub_mobile/core/widgets/bottom_action_bar.dart';
import 'package:event_hub_mobile/core/widgets/hold_timer.dart';
import 'package:event_hub_mobile/core/widgets/message_state.dart';
import 'package:event_hub_mobile/features/bookings/data/booking_repository.dart';
import 'package:event_hub_mobile/features/bookings/data/models/booking.dart';
import 'package:event_hub_mobile/features/bookings/presentation/providers/booking_providers.dart';
import 'package:event_hub_mobile/features/bookings/presentation/widgets/booking_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Pays for a booking with Stripe's payment sheet.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isPaying = false;
  bool _expired = false;

  bool get _stripeReady => !kIsWeb && Env.stripePublishableKey.isNotEmpty;

  Future<void> _pay(Booking booking) async {
    final messenger = ScaffoldMessenger.of(context);

    final secret = ref.read(paymentSecretsProvider)[booking.id];
    if (secret == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'This payment session has ended. Choose your tickets again.',
          ),
        ),
      );
      return;
    }
    if (!_stripeReady) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Payments aren’t set up in this build. Add STRIPE_PUBLISHABLE_KEY '
            'to env/dev.json and run the app again.',
          ),
        ),
      );
      return;
    }

    setState(() => _isPaying = true);
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: secret,
          merchantDisplayName: 'Event Hub',
          style: ThemeMode.light,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      await _confirm(booking.id);
      ref.invalidate(myBookingsProvider);
      // go (not push): the checkout and payment screens are done with.
      if (mounted) context.go(AppRoutes.orderSuccess(booking.id));
    } on StripeException catch (e) {
      // Closing the sheet is not a failure: stay here.
      if (e.error.code != FailureCode.Canceled && mounted) {
        context.pushReplacement(
          AppRoutes.paymentFailed(booking.id),
          extra: e.error.localizedMessage,
        );
      }
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  /// The money has been taken; wait a moment for the backend to see it. Asking
  /// Stripe directly means this does not depend on the webhook arriving.
  Future<void> _confirm(String bookingId) async {
    final repository = ref.read(bookingRepositoryProvider);
    for (var attempt = 0; attempt < 6; attempt++) {
      final booking = await repository.confirm(bookingId);
      if (booking.isConfirmed) return;
      await Future<void>.delayed(const Duration(milliseconds: 1200));
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider(widget.bookingId));
    final data = booking.value;

    return Scaffold(
      bottomNavigationBar: data == null
          ? null
          : BottomActionBar(
              above: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 6,
                children: [
                  Icon(LucideIcons.lock, size: 13, color: context.muted),
                  Text(
                    'Payments are encrypted and secure',
                    style: context.caption.copyWith(color: context.muted),
                  ),
                ],
              ),
              actionLabel: 'Pay ${formatMoney(data.totalPrice)}',
              isLoading: _isPaying,
              onPressed: _expired || !data.isPending ? null : () => _pay(data),
            ),
      body: Column(
        children: [
          const AppHeader(title: 'Payment'),
          Expanded(
            child: booking.when(
              loading: () => const Center(child: CircularProgressIndicator()),
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
              data: _content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(Booking booking) {
    final event = booking.event;

    return ListView(
      padding: const EdgeInsets.fromLTRB(bookingGutter, 12, bookingGutter, 24),
      children: [
        if (booking.isPending)
          HoldTimer(
            expiresAt: booking.expiresAt,
            onExpired: () => setState(() => _expired = true),
          ),
        const SizedBox(height: 20),
        Text(
          'PAYMENT METHOD',
          style: context.overline.copyWith(color: context.muted),
        ),
        const SizedBox(height: 10),
        BookingCard(
          padding: 16,
          child: Row(
            spacing: 14,
            children: [
              Container(
                width: 40,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEEEA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  LucideIcons.creditCard,
                  size: 18,
                  color: Color(0xFF3F434A),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Card or Apple Pay', style: context.bodyStrong),
                    Text(
                      'You’ll choose in a secure window',
                      style: context.meta.copyWith(color: context.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('SUMMARY', style: context.overline.copyWith(color: context.muted)),
        const SizedBox(height: 10),
        BookingCard(
          child: Column(
            spacing: 12,
            children: [
              PriceRow(
                '${booking.quantity} ${booking.quantity == 1 ? 'ticket' : 'tickets'}'
                '${event == null ? '' : ' · ${event.title}'}',
                formatMoney(booking.subtotal),
              ),
              if (booking.serviceFee > 0)
                PriceRow('Service fee', formatMoney(booking.serviceFee)),
              Divider(height: 1, thickness: 1, color: context.line),
              PriceRow('Total', formatMoney(booking.totalPrice), strong: true),
            ],
          ),
        ),
      ],
    );
  }
}
