import 'package:event_hub_mobile/core/theme/app_theme.dart';
import 'package:event_hub_mobile/features/events/data/models/event.dart';
import 'package:flutter/material.dart';

class TicketOptionTile extends StatelessWidget {
  final Ticket ticket;

  const TicketOptionTile({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isLowStock =
        !ticket.isSoldOut &&
        ticket.remainingQuantity <= (ticket.totalQuantity * 0.15);

    return Opacity(
      opacity: ticket.isSoldOut ? 0.5 : 1,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.card,
          border: Border.all(
            color: isLowStock
                ? AppColors.accent.withOpacity(0.5)
                : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Icon badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    color: AppColors.accent,
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
                              ? AppColors.accent
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
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            if (ticket.highlights.isNotEmpty) ...[
              const SizedBox(height: 6),
              ...ticket.highlights.map(
                (point) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check,
                        size: 13,
                        color: AppColors.accent,
                      ),
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
      ),
    );
  }
}
