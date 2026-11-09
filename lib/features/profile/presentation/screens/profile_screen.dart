import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/page_title.dart';
import 'package:event_hub_mobile/features/auth/data/models/user.dart';
import 'package:event_hub_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:event_hub_mobile/features/organizer/presentation/providers/organizer_providers.dart';
import 'package:event_hub_mobile/features/organizer/presentation/widgets/organizer_widgets.dart';
import 'package:event_hub_mobile/features/organizer/presentation/widgets/sales_summary_grid.dart';
import 'package:event_hub_mobile/core/widgets/skeleton.dart';
import 'package:event_hub_mobile/core/widgets/skeleton_pulse.dart';
import 'package:event_hub_mobile/features/bookings/presentation/widgets/booking_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The Profile tab: who is signed in and the log out button.
///
/// Only things that really work live here. Settings rows (payment methods,
/// notifications, ...) are left out until their screens exist.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitle('Profile'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                if (user != null) ...[
                  Row(
                    spacing: 14,
                    children: [
                      InitialsAvatar(user.fullName, size: 56),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.fullName, style: context.cardTitle),
                            Text(
                              user.email,
                              style: context.bodySmall.copyWith(
                                color: context.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (user.role != UserRole.attendee)
                        Pill(
                          user.role == UserRole.admin ? 'Admin' : 'Organizer',
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (user.role != UserRole.attendee) ...[
                    Text(
                      'YOUR NUMBERS',
                      style: context.overline.copyWith(color: context.muted),
                    ),
                    const SizedBox(height: 10),
                    ref
                        .watch(organizerSalesProvider)
                        .when(
                          loading: () => const SkeletonPulse(
                            child: Column(
                              spacing: 10,
                              children: [
                                Skeleton(height: 96, radius: 16),
                                Skeleton(height: 96, radius: 16),
                              ],
                            ),
                          ),
                          error: (_, _) => Text(
                            'Couldn’t load your numbers.',
                            style: context.bodySmall.copyWith(
                              color: context.muted,
                            ),
                          ),
                          data: (sales) => SalesSummaryGrid(sales: sales),
                        ),
                    const SizedBox(height: 24),
                  ],
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: context.danger,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 44),
                    ),
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                    icon: const Icon(LucideIcons.logOut, size: 18),
                    label: Text(
                      'Log out',
                      style: context.bodyEmphasis.copyWith(
                        color: context.danger,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
