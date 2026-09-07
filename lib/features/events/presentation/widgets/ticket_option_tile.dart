import 'package:event_hub_mobile/core/theme/app_theme.dart';
import 'package:event_hub_mobile/core/widgets/card.dart';
import 'package:event_hub_mobile/features/tickets/data/models/ticket.dart';
import 'package:flutter/material.dart';

// Cool blue accent used only within this tile — kept local rather
// than added to AppColors, since it's not a theme-wide color choice.
// Chosen specifically because it contrasts against the warm
// tan/brown used everywhere else, so this badge/price actually
// stands out instead of blending into the card.
const _ticketAccent = Color(0xFF4C8FE0);

// Gold — used specifically for price text, to make it stand out as
// its own distinct signal separate from the ticket type's blue accent.

class TicketOptionTile extends StatelessWidget {
  final Ticket ticket;

  const TicketOptionTile({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isLowStock =
        !ticket.isSoldOut &&
        ticket.remainingQuantity <= (ticket.totalQuantity * 0.15);

    return AppCard(
      disabled: ticket.isSoldOut,
      bordered: isLowStock,
      child: Column(
        children: [
          Row(
            children: [
              // Icon badge — bumped opacity + switched hue so it
              // actually registers against the card instead of
              // disappearing into it.
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _ticketAccent.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  color: _ticketAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.type,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      ticket.isSoldOut
                          ? 'Sold out'
                          : isLowStock
                          ? 'Only ${ticket.remainingQuantity} left — selling fast'
                          : '${ticket.remainingQuantity} of ${ticket.totalQuantity} left',
                      style: TextStyle(
                        color: ticket.isSoldOut
                            ? Colors.redAccent
                            : isLowStock
                            ? Colors.orangeAccent
                            : AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: isLowStock
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),
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

          const SizedBox(height: 10),

          if (ticket.highlights.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...ticket.highlights.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, size: 13, color: Colors.green),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
