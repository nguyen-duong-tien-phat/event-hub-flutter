import 'package:flutter/material.dart';
import 'package:event_hub_mobile/core/theme/app_theme.dart';

import '../../../events/data/models/event.dart';
import '../../data/models/ticket_selection_item.dart';

class OrderSummaryScreen extends StatefulWidget {
  final Event event;
  final List<TicketSelectionItem> selections;

  const OrderSummaryScreen({
    super.key,
    required this.event,
    required this.selections,
  });

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  final _emailController = TextEditingController();

  // Simple presence + "@" check — good enough client-side; real
  // validation always still happens on the backend regardless.
  bool get _isEmailValid => _emailController.text.trim().contains('@');

  double get _subtotal =>
      widget.selections.fold(0, (sum, item) => sum + item.subtotal);

  // Flat 5% service fee — adjust or replace with your backend's
  // actual fee calculation once that exists.
  double get _serviceFee => _subtotal * 0.05;

  double get _total => _subtotal + _serviceFee;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text('Order Summary'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.event.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.event.formattedDate} · ${widget.event.formattedTime}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),

          const SizedBox(height: 24),

          // --- Ticket breakdown ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                ...widget.selections.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.ticket.type} × ${item.quantity}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          '\$${item.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(color: AppColors.border, height: 20),
                _SummaryRow(label: 'Subtotal', value: _subtotal),
                const SizedBox(height: 6),
                _SummaryRow(label: 'Service fee', value: _serviceFee),
                const Divider(color: AppColors.border, height: 20),
                _SummaryRow(label: 'Total', value: _total, isBold: true),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Contact email',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your tickets and receipt will be sent here.',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.textPrimary),
              cursorColor: AppColors.accent,
              onChanged: (_) => setState(() {}), // re-check validity live
              decoration: const InputDecoration(
                hintText: 'you@example.com',
                hintStyle: TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
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
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isEmailValid
                ? () {
                    // Navigate to Payment Method screen — next step
                    // once that's built.
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentStrong,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Continue to Payment · \$${_total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: isBold ? AppColors.textPrimary : AppColors.textMuted,
      fontSize: isBold ? 16 : 13,
      fontWeight: isBold ? FontWeight.w800 : FontWeight.w400,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text('\$${value.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}
