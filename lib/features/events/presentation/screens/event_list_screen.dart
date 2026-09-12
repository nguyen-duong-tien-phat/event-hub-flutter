import 'package:event_hub_mobile/core/theme/app_theme.dart';
import 'package:event_hub_mobile/features/auth/presentations/provider/auth_provider.dart';
import 'package:event_hub_mobile/features/events/data/repositories/event_repository.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../data/models/category.dart';
import '../../data/models/event.dart';
import '../widgets/category_pill.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

final Geocoding _geocoding = Geocoding();

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final EventRepository _eventRepository = EventRepository();

  String? _locationText;
  bool _permissionDenied = false;
  String _selectedKey = 'my_feed';
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchEvents();

    if (!mounted) return;

    _getCurrentLocation();
  }

  Future<void> _fetchEvents() async {
    try {
      final events = await _eventRepository.getEvents(page: 1, size: 10);

      if (!mounted) return;

      setState(() {
        _events = events;
        // _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      // setState(() {
      //   _error = e.toString();
      //   _isLoading = false;
      // });
    }
  }

  Future<void> _getCurrentLocation() async {
    var permission = await Geolocator.checkPermission();

    if (!mounted) return;

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (!mounted) return;

      if (permission == LocationPermission.denied) {
        setState(() => _permissionDenied = true);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _permissionDenied = true);
      return;
    }

    final position = await Geolocator.getCurrentPosition();

    if (!mounted) return;

    final placemarks = await _geocoding.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (!mounted) return;

    final place = placemarks.first;

    setState(
      () => _locationText = '${place.locality}, ${place.isoCountryCode}',
    );
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                children: [
                  const Spacer(),

                  // Location
                  if (!_permissionDenied)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.mapPin,
                          color: AppColors.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        _locationText == null
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accent,
                                ),
                              )
                            : Text(
                                _locationText!,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ],
                    ),

                  const Spacer(),

                  // Logout
                  IconButton(
                    onPressed: _logout,
                    icon: const Icon(
                      LucideIcons.logOut,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    tooltip: 'Logout',
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- Category pills ---
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: defaultCategories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: CategoryPill(
                        icon: category.icon,
                        label: category.label,
                        isSelected: category.key == _selectedKey,
                        onTap: () {
                          setState(() {
                            _selectedKey = category.key;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // --- Event list ---
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: EventCard(
                        event: event,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailScreen(id: event.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
