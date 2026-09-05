import 'package:event_hub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models/category.dart';
import '../widgets/category_pill.dart';

final Geocoding _geocoding = Geocoding();

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  String? _locationText;
  bool _permissionDenied = false;
  String _selectedKey = 'my_feed';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
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

    // geocoding v5.0.0 uses an instance-based API: create a Geocoding()
    // instance and call methods on it (not a top-level function).
    final placemarks = await _geocoding.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final place = placemarks.first;

    setState(() {
      _locationText = '${place.locality}, ${place.isoCountryCode}';
    });
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
              const SizedBox(height: 12),

              // --- Location ---
              if (!_permissionDenied)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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

              const SizedBox(height: 20),

              // --- Search bar ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.search,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        cursorColor: AppColors.accent,
                        decoration: InputDecoration(
                          hintText: 'Search events...',
                          hintStyle: const TextStyle(
                            color: AppColors.textMuted,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
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
            ],
          ),
        ),
      ),
    );
  }
}
