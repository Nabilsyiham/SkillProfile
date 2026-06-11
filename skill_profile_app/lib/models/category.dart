import 'package:flutter/material.dart';

class AppCategory {
  final String name;
  final IconData icon;
  final Color color;

  const AppCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

final List<AppCategory> categories = [
  const AppCategory(name: 'Cardigan', icon: Icons.checkroom, color: Color(0xFFE8B4B8)),
  const AppCategory(name: 'Bags', icon: Icons.shopping_bag, color: Color(0xFFB8E8B4)),
  const AppCategory(name: 'Shoes', icon: Icons.shopping_cart, color: Color(0xFFE8D4B4)),
  const AppCategory(name: 'Pants', icon: Icons.dry_cleaning, color: Color(0xFFB4D4E8)),
  const AppCategory(name: 'Shirt', icon: Icons.texture, color: Color(0xFFD4B4E8)),
];
