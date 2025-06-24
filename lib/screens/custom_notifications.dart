import 'package:flutter/material.dart';
import 'theme_controller.dart'; // 👈 Thème dynamique

class CustomNotifications extends StatelessWidget {
  const CustomNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = ThemeController();
    final Color color = themeController.currentColor;

    return Center(
      child: Text(
        'Notifications personnalisées – À venir',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
