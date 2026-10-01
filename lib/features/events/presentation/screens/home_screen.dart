import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/app_navigation_bar.dart';
import 'package:event_hub_mobile/core/widgets/app_text_field.dart';
import 'package:event_hub_mobile/features/auth/data/models/user.dart';
import 'package:event_hub_mobile/features/events/data/models/event_summary.dart';
import 'package:event_hub_mobile/features/events/presentation/widgets/category_chips.dart';
import 'package:event_hub_mobile/features/events/presentation/widgets/event_item.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AppNavigationBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Events near', style: context.caption),
                      Text('San Francisco, US', style: context.link),
                    ],
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: context.accent.withValues(alpha: 0.07),
                    child: Text(
                      'FN',
                      style: context.link.copyWith(color: context.accent),
                    ),
                  ),
                ],
              ),

              // BODY
              Padding(
                padding: EdgeInsets.only(top: 18, bottom: 16),
                child: Text('Discover', style: context.display),
              ),

              // SEARCH
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      hint: 'Search events, venues, artists',
                      prefixIcon: Icon(LucideIcons.search),
                    ),
                  ),

                  SizedBox(width: 10),

                  AppButton.icon(
                    tooltip: 'Filter',
                    variant: AppButtonVariant.secondary,
                    icon: LucideIcons.sliders,
                    onPressed: () {},
                  ),
                ],
              ),

              SizedBox(height: 8),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: CategoryChips(
                  categories: ['My feed', 'Concerts', 'Food', 'Art'],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text('Featured this week', style: context.headline),

                      SizedBox(height: 10),
                      EventItem(
                        variant: EventItemVariant.featured,
                        event: EventSummary(
                          id: 'id',
                          title: 'Midnight Echoes Live',
                          organizer: User(
                            id: 'user',
                            email: 'email',
                            fullName: 'Fort Mason Center',
                            role: UserRole.organizer,
                          ),
                          startsAt: DateTime(2026, 1, 1, 20, 0, 0),
                          location: 'The Fillmore',
                          imageUrl: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=600&h=400&fit=crop',
                        ),
                      ),

                      SizedBox(height: 28),

                      Text('This weekend', style: context.headline),

                      SizedBox(height: 10),
                      EventItem(
                        event: EventSummary(
                          id: 'id',
                          title: 'Midnight Echoes Live',
                          organizer: User(
                            id: 'user',
                            email: 'email',
                            fullName: 'Fort Mason Center',
                            role: UserRole.organizer,
                          ),
                          startsAt: DateTime(2026, 1, 1, 20, 0, 0),
                          location: 'The Fillmore',
                          imageUrl: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=600&h=400&fit=crop',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
