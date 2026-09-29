import 'package:flutter/material.dart';

/// Text styles from the design, mapped onto Material's TextTheme slots.
///
/// Flutter units differ from the design file:
/// - letterSpacing is in logical pixels, not em: -2% at 28px = -0.56.
/// - height is a line-height multiplier (1.5 = 150%).
class AppTextTheme {
  static const TextTheme base = TextTheme(
    // Display — screen titles ("Discover", "Tickets", "Welcome back").
    displaySmall: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.56,
    ),

    // Title — empty/error state headings, bottom-bar prices.
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
    ),

    // Card title — order confirmation event name, profile name.
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.18,
    ),

    // Headline — section headings ("Featured this week").
    titleMedium: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.17,
    ),

    // Subhead — top bar titles, ticket names, featured card titles.
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),

    // Body — paragraphs, input text, settings rows.
    bodyLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),

    // Body small — state descriptions, price breakdown lines.
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),

    // Caption — helper/error text, legal text.
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),

    // Body strong — list row titles, button labels (buttons use this slot).
    labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),

    // Control — chips, segmented control, filter options.
    labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),

    // Field label — labels above inputs, "Forgot password?".
    labelSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
  );
}
