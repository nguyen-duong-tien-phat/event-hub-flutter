import 'package:event_hub_mobile/features/events/presentation/widgets/date_time.dart';
import 'package:event_hub_mobile/features/events/presentation/widgets/ticket_option_tile.dart';
import 'package:flutter/material.dart';
import 'package:event_hub_mobile/core/theme/app_theme.dart';

import '../../data/models/event.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: AppColors.detailBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.detailBackground,
            leading: _CircleIconButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
            actions: [
              _CircleIconButton(icon: Icons.share, onTap: () {}),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(event.imageUrl, fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.5, 1.0],
                        colors: [
                          Colors.transparent,
                          AppColors.detailBackground.withOpacity(0.55),
                          AppColors.detailBackground,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: AppColors.textOnDark,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    event.location,
                    style: const TextStyle(
                      color: AppColors.textMutedOnDark,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: DateTimeWidget(event: event)),
                      if (event.formattedPrice != null) ...[
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.detailCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.detailBorder),
                          ),
                          child: Text(
                            event.formattedPrice!,
                            style: const TextStyle(
                              color: AppColors.accentOnDark,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'About this event',
                    style: TextStyle(
                      color: AppColors.textOnDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: const TextStyle(
                      color: AppColors.textMutedOnDark,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),

                  if (event.highlights.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    ...event.highlights.map(
                      (point) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 18,
                              color: AppColors.accentOnDark,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                point,
                                style: const TextStyle(
                                  color: AppColors.textOnDark,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  if (event.tickets.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    const Text(
                      'Ticket options',
                      style: TextStyle(
                        color: AppColors.textOnDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...event.tickets.map(
                      (ticket) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TicketOptionTile(ticket: ticket),
                      ),
                    ),
                  ],

                  if (event.organizer != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Organizer',
                      style: TextStyle(
                        color: AppColors.textOnDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.organizer!.fullName,
                      style: const TextStyle(
                        color: AppColors.textMutedOnDark,
                        fontSize: 14,
                      ),
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.detailBackground,
          border: Border(
            top: BorderSide(color: AppColors.detailBorder, width: 1),
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _isSaved = !_isSaved),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.detailCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.detailBorder),
                ),
                child: Icon(
                  _isSaved ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.accentOnDark,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: event.tickets.isEmpty
                      ? null
                      : () {
                          // Navigate to ticket selection — next step
                          // once that screen exists.
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    event.tickets.isEmpty ? 'Sold Out' : 'Get a Ticket',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.4),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
