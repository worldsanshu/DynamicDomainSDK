import 'package:flutter/material.dart';

class CategoryIcon {
  final IconData icon;
  final Color color;
  final Color selectedColor;

  const CategoryIcon({
    required this.icon,
    this.color = const Color(0xFF6B7280),
    this.selectedColor = const Color(0xFF4F42FF),
  });
}

class CategoryIcons {
  static const CategoryIcon recommendationIcon =
      CategoryIcon(icon: Icons.search_rounded);

  static const CategoryIcon recentIcon =
      CategoryIcon(icon: Icons.access_time_rounded);

  static const CategoryIcon smileyIcon =
      CategoryIcon(icon: Icons.sentiment_satisfied_alt_rounded);

  static const CategoryIcon peopleIcon =
      CategoryIcon(icon: Icons.person_rounded);

  static const CategoryIcon animalIcon = CategoryIcon(icon: Icons.pets_rounded);

  static const CategoryIcon foodIcon =
      CategoryIcon(icon: Icons.restaurant_rounded);

  static const CategoryIcon travelIcon =
      CategoryIcon(icon: Icons.flight_rounded);

  static const CategoryIcon activityIcon =
      CategoryIcon(icon: Icons.sports_soccer_rounded);

  static const CategoryIcon objectIcon =
      CategoryIcon(icon: Icons.lightbulb_rounded);

  static const CategoryIcon symbolIcon =
      CategoryIcon(icon: Icons.psychology_rounded);

  static const CategoryIcon flagIcon = CategoryIcon(icon: Icons.flag_rounded);
}
