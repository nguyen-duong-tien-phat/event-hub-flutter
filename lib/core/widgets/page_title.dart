import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// Big title at the top of a main tab ("Tickets", "Saved", "Profile").
class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: context.display),
      ),
    );
  }
}
