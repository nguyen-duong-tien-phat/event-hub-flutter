import 'dart:math' as math;

import 'package:event_hub_mobile/core/network/api_exception.dart';
import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/utils/money.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/app_header.dart';
import 'package:event_hub_mobile/core/widgets/bottom_action_bar.dart';
import 'package:event_hub_mobile/core/widgets/message_state.dart';
import 'package:event_hub_mobile/core/widgets/skeleton.dart';
import 'package:event_hub_mobile/core/widgets/skeleton_pulse.dart';
import 'package:event_hub_mobile/features/bookings/data/booking_repository.dart';
import 'package:event_hub_mobile/features/bookings/presentation/providers/booking_providers.dart';
import 'package:event_hub_mobile/features/bookings/presentation/widgets/booking_widgets.dart';
import 'package:event_hub_mobile/features/events/data/models/event.dart';
import 'package:event_hub_mobile/features/events/presentation/providers/events_provider.dart';
import 'package:event_hub_mobile/features/tickets/data/models/ticket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';

/// Pick how many of each ticket type, then hold them and go to checkout.
class SelectTicketsScreen extends ConsumerWidget {
  const SelectTicketsScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventDetailProvider(eventId));

    return event.when(
      loading: () => const _Frame(child: _Skeleton()),
      error: (error, _) => _Frame(
        child: MessageState(
          icon: LucideIcons.wifiOff,
          title: 'Couldn’t load tickets',
          message: error is ApiException
              ? error.message
              : 'Check your connection and try again.',
          action: AppButton(
            label: 'Try again',
            variant: AppButtonVariant.dark,
            onPressed: () => ref.invalidate(eventDetailProvider(eventId)),
          ),
        ),
      ),
      data: (event) => _Picker(event: event),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child, this.bottom});

  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottom,
      body: Column(
        children: [
          const AppHeader(title: 'Select tickets'),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Picker extends ConsumerStatefulWidget {
  const _Picker({required this.event});

  final Event event;

  @override
  ConsumerState<_Picker> createState() => _PickerState();
}

class _PickerState extends ConsumerState<_Picker> {
  /// Ticket id -> how many.
  final Map<String, int> _quantities = {};

  /// One key per intent to book. Kept while the user retries the same choice,
  /// replaced when they change it or once the booking is made.
  String? _idempotencyKey;
  bool _isLoading = false;

  int get _count => _quantities.values.fold(0, (a, b) => a + b);

  double get _total => widget.event.tickets.fold(
    0,
    (sum, t) => sum + t.price * (_quantities[t.id] ?? 0),
  );

  int _maxFor(Ticket ticket) =>
      math.min(ticket.maxPerOrder, ticket.remainingQuantity);

  void _set(Ticket ticket, int quantity) {
    _idempotencyKey = null; // a different choice is a different intent
    setState(() {
      if (quantity <= 0) {
        _quantities.remove(ticket.id);
      } else {
        _quantities[ticket.id] = quantity;
      }
    });
  }

  Future<void> _continue() async {
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final booking = await ref
          .read(bookingRepositoryProvider)
          .create(
            widget.event.id,
            _quantities,
            idempotencyKey: _idempotencyKey ??= const Uuid().v4(),
          );
      _idempotencyKey = null; // done: the next booking is a new intent
      final secret = booking.clientSecret;
      if (secret != null) {
        ref.read(paymentSecretsProvider.notifier).put(booking.id, secret);
      }
      if (mounted) context.push(AppRoutes.checkout(booking.id));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      // Someone else may have taken the tickets: refresh what is left.
      if (e is ConflictException) {
        ref.invalidate(eventDetailProvider(widget.event.id));
        setState(_quantities.clear);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final count = _count;

    return _Frame(
      bottom: BottomActionBar(
        leading: BottomBarLabel(
          caption: count == 0
              ? 'No tickets yet'
              : '$count ${count == 1 ? 'ticket' : 'tickets'}',
          value: formatMoney(_total),
        ),
        actionLabel: 'Continue',
        isLoading: _isLoading,
        onPressed: count == 0 ? null : _continue,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          bookingGutter,
          12,
          bookingGutter,
          24,
        ),
        children: [
          EventMiniCard(
            imageUrl: event.imageUrl,
            title: event.title,
            meta: eventMeta(event.startsAt, event.location),
          ),
          const SizedBox(height: 18),
          if (event.tickets.isEmpty)
            Text(
              'Tickets for this event aren’t on sale yet.',
              style: context.bodySmall.copyWith(color: context.muted),
            ),
          for (final ticket in event.tickets) ...[
            _TicketCard(
              ticket: ticket,
              quantity: _quantities[ticket.id] ?? 0,
              max: _maxFor(ticket),
              onChanged: (q) => _set(ticket, q),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.quantity,
    required this.max,
    required this.onChanged,
  });

  final Ticket ticket;
  final int quantity;
  final int max;
  final ValueChanged<int> onChanged;

  static const _lowStock = 10;

  @override
  Widget build(BuildContext context) {
    final soldOut = ticket.remainingQuantity == 0;
    final selected = quantity > 0;
    final lowStock = !soldOut && ticket.remainingQuantity <= _lowStock;

    return Opacity(
      opacity: soldOut ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? context.ink : context.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              spacing: 12,
              children: [
                Expanded(child: Text(ticket.type, style: context.subhead)),
                Text(formatPrice(ticket.price), style: context.subhead),
              ],
            ),
            if (ticket.highlights.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  for (final item in ticket.highlights)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            LucideIcons.check,
                            size: 16,
                            color: context.success,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: context.bodySmall.copyWith(
                              color: const Color(0xFF3F434A),
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            Divider(height: 1, thickness: 1, color: context.line),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (soldOut)
                  const _SoldOutBadge()
                else if (lowStock)
                  Text(
                    'Only ${ticket.remainingQuantity} left',
                    style: context.fieldLabel.copyWith(
                      color: const Color(0xFF9A5B00),
                    ),
                  )
                else
                  Text(
                    'Max ${ticket.maxPerOrder} per order',
                    style: context.meta.copyWith(color: context.muted),
                  ),
                if (!soldOut)
                  _Stepper(
                    quantity: quantity,
                    canAdd: quantity < max,
                    onChanged: onChanged,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SoldOutBadge extends StatelessWidget {
  const _SoldOutBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEEEA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Sold out',
        style: context.badge.copyWith(color: const Color(0xFF3F434A)),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.quantity,
    required this.canAdd,
    required this.onChanged,
  });

  final int quantity;
  final bool canAdd;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4,
      children: [
        _RoundButton(
          icon: LucideIcons.minus,
          tooltip: 'Remove one',
          onTap: quantity > 0 ? () => onChanged(quantity - 1) : null,
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: context.subhead,
          ),
        ),
        _RoundButton(
          icon: LucideIcons.plus,
          tooltip: 'Add one',
          onTap: canAdd ? () => onChanged(quantity + 1) : null,
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.tooltip, this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: context.surface,
      shape: CircleBorder(
        side: BorderSide(
          color: enabled ? context.line : const Color(0xFFEFEEEA),
        ),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox.square(
            dimension: 36,
            child: Icon(
              icon,
              size: 16,
              color: enabled ? context.ink : const Color(0xFFB8BBC0),
            ),
          ),
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          bookingGutter,
          12,
          bookingGutter,
          24,
        ),
        children: [
          const Row(
            spacing: 12,
            children: [
              Skeleton(width: 48, height: 48, radius: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Skeleton(width: 180, height: 16),
                  Skeleton(width: 140, height: 12),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < 2; i++) ...[
            const Skeleton(height: 150, radius: 16),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
