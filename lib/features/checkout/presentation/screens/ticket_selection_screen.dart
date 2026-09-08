import 'package:event_hub_mobile/core/widgets/card.dart';
import 'package:event_hub_mobile/core/widgets/primary_button.dart';
import 'package:event_hub_mobile/features/tickets/data/models/ticket.dart';
import 'package:flutter/material.dart';
import 'package:event_hub_mobile/core/theme/app_theme.dart';

import '../../../events/data/models/event.dart';
import '../../data/models/ticket_selection_item.dart';
import 'order_summary_screen.dart';

class TicketSelectionScreen extends StatefulWidget {
  final Event event;

  const TicketSelectionScreen({super.key, required this.event});

  @override
  State<TicketSelectionScreen> createState() => _TicketSelectionScreenState();
}

class _TicketSelectionScreenState extends State<TicketSelectionScreen> {
  final Map<String, int> _quantities = {};

  int _quantityFor(String ticketId) => _quantities[ticketId] ?? 0;

  void _setQuantity(Ticket ticket, int value) {
    setState(() {
      _quantities[ticket.id] = value.clamp(0, ticket.effectiveMaxQuantity);
    });
  }

  double get _totalPrice {
    double total = 0;
    for (final ticket in widget.event.tickets) {
      total += ticket.price * _quantityFor(ticket.id);
    }
    return total;
  }

  int get _totalTicketCount =>
      _quantities.values.fold(0, (sum, qty) => sum + qty);

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text('Select Tickets'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...event.tickets.map(
            (ticket) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _TicketSelectorCard(
                ticket: ticket,
                quantity: _quantityFor(ticket.id),
                onChanged: (value) => _setQuantity(ticket, value),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$_totalTicketCount ticket${_totalTicketCount == 1 ? '' : 's'} · ',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '\$${_totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Continue',
              onPressed: _totalTicketCount == 0
                  ? null
                  : () {
                      final selections = event.tickets
                          .where((t) => _quantityFor(t.id) > 0)
                          .map(
                            (t) => TicketSelectionItem(
                              ticket: t,
                              quantity: _quantityFor(t.id),
                            ),
                          )
                          .toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderSummaryScreen(
                            event: event,
                            selections: selections,
                          ),
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}

/// Redesigned into three clear sections separated by dividers, instead
/// of cramming type/price/highlights/stepper into one dense block:
/// 1. Type + price
/// 2. Highlights (if any)
/// 3. Quantity stepper, on its own row with a label
class _TicketSelectorCard extends StatelessWidget {
  final Ticket ticket;
  final int quantity;
  final ValueChanged<int> onChanged;

  const _TicketSelectorCard({
    required this.ticket,
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      disabled: ticket.isSoldOut,
      bordered: quantity > 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Section 1: type + price ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  ticket.type,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '\$${ticket.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          // --- Section 2: highlights ---
          if (ticket.highlights.isNotEmpty) ...[
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ticket.highlights
                  .map(
                    (point) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              point,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12.5,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 14),

          // --- Section 3: quantity, on its own labeled row ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (ticket.isSoldOut)
                const Text(
                  'Sold out',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ticket.remainingQuantity} available',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      // Set by the organizer per ticket type — not a
                      // hardcoded app-wide rule.
                      'Max ${ticket.maxPerOrder} per order',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              if (!ticket.isSoldOut)
                _QuantityStepper(
                  quantity: quantity,
                  maxQuantity: ticket.effectiveMaxQuantity,
                  onChanged: onChanged,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stepper that supports both tapping +/- and typing a number directly.
/// Needs to be a StatefulWidget (unlike most of our small widgets) to
/// own a TextEditingController — the controller is what lets a
/// TextField read/write what's currently typed, and must be manually
/// kept in sync whenever `quantity` changes from outside (e.g. a +/-
/// tap), which is what didUpdateWidget below handles.
class _QuantityStepper extends StatefulWidget {
  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  const _QuantityStepper({
    required this.quantity,
    required this.maxQuantity,
    required this.onChanged,
  });

  @override
  State<_QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<_QuantityStepper> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.quantity}');
  }

  @override
  void didUpdateWidget(_QuantityStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the quantity changed from outside (a +/- tap elsewhere),
    // update the text field to match — but only if it's not what the
    // user is actively typing, to avoid fighting their cursor.
    final external = '${widget.quantity}';
    if (_controller.text != external) {
      _controller.text = external;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final parsed = int.tryParse(value) ?? 0;
    widget.onChanged(parsed.clamp(0, widget.maxQuantity));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          icon: Icons.remove,
          onTap: widget.quantity > 0
              ? () => widget.onChanged(widget.quantity - 1)
              : null,
        ),
        SizedBox(
          width: 40,
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 6),
            ),
            // Fires when the field loses focus or the user taps
            // "done" on the keyboard — not on every keystroke, so a
            // half-typed number (e.g. "1" while typing "12") doesn't
            // get clamped away before they finish typing.
            onSubmitted: _submit,
            onTapOutside: (_) => _submit(_controller.text),
          ),
        ),
        _StepperButton(
          icon: Icons.add,
          onTap: widget.quantity < widget.maxQuantity
              ? () => widget.onChanged(widget.quantity + 1)
              : null,
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.border,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled ? AppColors.accent : AppColors.textMuted,
        ),
      ),
    );
  }
}
