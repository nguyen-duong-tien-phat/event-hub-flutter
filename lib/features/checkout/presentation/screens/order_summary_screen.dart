import 'package:event_hub_mobile/core/theme/app_theme.dart';
import 'package:event_hub_mobile/core/widgets/card.dart';
import 'package:event_hub_mobile/core/widgets/divider.dart';
import 'package:event_hub_mobile/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../events/data/models/event.dart';
import '../../data/models/ticket_selection_item.dart';

class OrderSummaryScreen extends StatelessWidget {
  final Event event;
  final List<TicketSelectionItem> selections;

  const OrderSummaryScreen({
    super.key,
    required this.event,
    required this.selections,
  });

  double get _subtotal =>
      selections.fold(0, (sum, item) => sum + item.subtotal);

  double get _serviceFee => _subtotal * 0.02;

  double get _total => _subtotal + _serviceFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Order Summary',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const _SectionTitle(title: 'ORDER DETAILS'),
          const SizedBox(height: 5),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                _SummaryRow(label: 'Date', value: event.fullDate),
                _SummaryRow(label: 'Time', value: event.formattedTime),

                AppDivider(dash: true),

                ...selections.map(
                  (item) => _SummaryRow(
                    label:
                        '${item.ticket.type} (${item.quantity} x \$${item.ticket.price})',
                    value: '\$${item.subtotal.toStringAsFixed(2)}',
                  ),
                ),

                AppDivider(dash: true),

                _SummaryRow(
                  label: 'Subtotal',
                  value: '\$${_subtotal.toStringAsFixed(2)}',
                ),
                _SummaryRow(
                  label: 'Service fee (1%)',
                  value: '\$${_serviceFee.toStringAsFixed(2)}',
                ),

                SizedBox(height: 8),

                _SummaryRow(
                  label: 'Total',
                  value: '\$${_total.toStringAsFixed(2)}',
                  isTotal: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const _SectionTitle(title: 'ACCOUNT'),

          const SizedBox(height: 5),

          const AppCard(
            child: Row(
              children: [
                Icon(LucideIcons.user, size: 24, color: AppColors.accent),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nguyen Duong Tien Phat',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'finn@example.com',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              'Tickets will be sent to the email associated with your account.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: PrimaryButton(label: 'Continue to Payment', onPressed: () {}),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isTotal ? AppColors.textPrimary : AppColors.textMuted,
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: isTotal ? AppColors.gold : AppColors.textPrimary,
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
