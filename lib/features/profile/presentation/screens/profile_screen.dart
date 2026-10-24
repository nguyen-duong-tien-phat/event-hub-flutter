import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/page_title.dart';
import 'package:event_hub_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:event_hub_mobile/features/bookings/presentation/widgets/booking_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The Profile tab: who is signed in, a few settings rows and log out.
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
                if (user != null)
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
                    ],
                  ),
                const SizedBox(height: 24),
                const _Section('Account', [
                  _Row(LucideIcons.userRound, 'Personal info'),
                  _Row(LucideIcons.creditCard, 'Payment methods'),
                  _Row(LucideIcons.bell, 'Notifications'),
                ]),
                const SizedBox(height: 24),
                const _Section('Preferences', [
                  _Row(LucideIcons.mapPin, 'Location'),
                  _Row(LucideIcons.star, 'Interests'),
                ]),
                const SizedBox(height: 24),
                const _Section('Support', [
                  _Row(LucideIcons.circleQuestionMark, 'Help center'),
                  _Row(LucideIcons.fileText, 'Terms & privacy'),
                ]),
                const SizedBox(height: 24),
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

class _Section extends StatelessWidget {
  const _Section(this.title, this.rows);

  final String title;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          title.toUpperCase(),
          style: context.overline.copyWith(color: context.muted),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.surface,
            border: Border.all(color: context.line),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: Color(0xFFEFEEEA)),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A settings row. None of them has a screen yet, so they say so.
// TODO: give each row its own screen.
class _Row extends StatelessWidget {
  const _Row(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$label is coming soon'))),
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            spacing: 14,
            children: [
              Icon(icon, size: 19, color: const Color(0xFF3F434A)),
              Expanded(child: Text(label, style: context.body)),
              const Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: Color(0xFFA6A9AE),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
