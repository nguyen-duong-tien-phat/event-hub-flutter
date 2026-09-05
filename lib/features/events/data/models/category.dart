import 'package:flutter/material.dart';

class Category {
  final String key;
  final IconData icon;
  final String label;

  const Category({required this.key, required this.icon, required this.label});
}

// Default categories shown on the event list screen.
// Move this to a repository/API call later once categories are dynamic.
const List<Category> defaultCategories = [
  Category(key: 'my_feed', icon: Icons.bolt, label: 'My feed'),
  Category(key: 'food', icon: Icons.restaurant, label: 'Food'),
  Category(key: 'concerts', icon: Icons.music_note, label: 'Concerts'),
];
