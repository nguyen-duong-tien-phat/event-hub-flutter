import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/app_header.dart';
import 'package:event_hub_mobile/core/widgets/hold_timer.dart';
import 'package:event_hub_mobile/features/bookings/data/booking_repository.dart';
import 'package:event_hub_mobile/features/bookings/presentation/providers/booking_providers.dart';
import 'package:event_hub_mobile/features/bookings/presentation/widgets/booking_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The payment did not go through. The tickets stay held for a while.
class PaymentFailedScreen extends ConsumerWidget {
  const PaymentFailedScreen({super.key, required this.bookingId, this.reason});

  final String bookingId;

  /// What the payment provider said, if anything.
  final String? reason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider(bookingId)).value;
    final message =
        '${reason ?? 'Your payment couldn’t be processed.'} '
        'You haven’t been charged, and your tickets are still held for you.';

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: bookingGutter),
              children: [
                const SizedBox(height: 56),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFBECEA),
                    ),
                    child: Icon(
                      LucideIcons.circleAlert,
                      size: 28,
                      color: context.danger,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Payment didn’t go through',
                  textAlign: TextAlign.center,
                  style: context.title,
                ),
                const SizedBox(height: 8),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: context.bodySmall.copyWith(color: context.muted),
                    ),
                  ),
                ),
                if (booking != null && booking.isPending) ...[
                  const SizedBox(height: 24),
                  HoldTimer(expiresAt: booking.expiresAt),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: bookingGutter),
              child: Column(
                spacing: 10,
                children: [
                  AppButton(
                    label: 'Try again',
                    variant: AppButtonVariant.dark,
                    size: AppButtonSize.large,
                    expand: true,
                    onPressed: () =>
                        context.pushReplacement(AppRoutes.payment(bookingId)),
                  ),
                  AppButton(
                    label: 'Cancel booking',
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.large,
                    expand: true,
                    onPressed: () async {
                      await ref
                          .read(bookingRepositoryProvider)
                          .releaseIfPending(bookingId);
                      if (context.mounted) context.go(AppRoutes.home);
                    },
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
