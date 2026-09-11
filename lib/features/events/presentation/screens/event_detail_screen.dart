import 'package:event_hub_mobile/core/theme/app_theme.dart';
import 'package:event_hub_mobile/core/widgets/snack_bar.dart';
import 'package:event_hub_mobile/features/auth/presentations/screens/splash_screen.dart';
import 'package:event_hub_mobile/features/checkout/presentation/screens/ticket_selection_screen.dart';
import 'package:event_hub_mobile/features/events/data/repositories/event_repository.dart';
import 'package:event_hub_mobile/features/events/presentation/widgets/date_time.dart';
import 'package:event_hub_mobile/features/events/presentation/widgets/ticket_option_tile.dart';
import 'package:flutter/material.dart';

import '../../data/models/event.dart';

class EventDetailScreen extends StatefulWidget {
  final String id;

  const EventDetailScreen({super.key, required this.id});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventRepository eventRepository = EventRepository();

  bool _isSaved = false;
  bool _isFetching = true;
  Event? _event;

  @override
  void initState() {
    super.initState();
    _fetchEventDetail();
  }

  Future<void> _fetchEventDetail() async {
    try {
      final eventDetail = await eventRepository.getEventDetail(widget.id);
      setState(() => _event = eventDetail);
    } catch (e) {
      showErrorSnackBar(context, e.toString());
    } finally {
      setState(() => _isFetching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) return SplashScreen();
    if (_event == null) return Text('Event Not Found!');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: _CircleIconButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.pop(context),
            ),
            actions: [
              _CircleIconButton(icon: Icons.share, onTap: () {}),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [Image.network(_event!.imageUrl, fit: BoxFit.cover)],
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
                    _event!.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _event!.location,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: DateTimeWidget(event: _event!)),
                      if (_event!.formattedPrice != null) ...[
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            _event!.formattedPrice!,
                            style: const TextStyle(
                              color: AppColors.gold,
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
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _event!.description,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),

                  if (_event!.highlights.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    ..._event!.highlights.map(
                      (point) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                point,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
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

                  if (_event!.tickets.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    const Text(
                      'Ticket options',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._event!.tickets.map(
                      (ticket) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TicketOptionTile(ticket: ticket),
                      ),
                    ),
                  ],

                  if (_event!.organizer != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Organizer',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _event!.organizer!.fullName,
                      style: const TextStyle(
                        color: AppColors.textMuted,
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
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _isSaved = !_isSaved),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  _isSaved ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _event!.tickets.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TicketSelectionScreen(event: _event!),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentStrong,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _event!.tickets.isEmpty ? 'Sold Out' : 'Get a Ticket',
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
          backgroundColor: Colors.black.withValues(alpha: 0.6),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
