import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static final ThemeController _instance = ThemeController._internal();
  factory ThemeController() => _instance;
  ThemeController._internal();

  final ValueNotifier<MaterialColor> themeColor = ValueNotifier(Colors.deepPurple);

  /// Accès direct à la couleur actuelle
  MaterialColor get currentColor => themeColor.value;

  /// Charge la couleur enregistrée au lancement
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final int? colorValue = prefs.getInt('selectedThemeColor');
    if (colorValue != null) {
      themeColor.value = _getMaterialColorFromValue(colorValue);
    }
  }

  /// Définit et sauvegarde la nouvelle couleur
  Future<void> setColor(MaterialColor color) async {
    themeColor.value = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedThemeColor', color.value);
  }

  /// Convertit un int vers un MaterialColor
  MaterialColor _getMaterialColorFromValue(int value) {
    return <MaterialColor>[
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
    ].firstWhere((color) => color.value == value, orElse: () => Colors.deepPurple);
  }
}
