import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Contrôleur de thème global
class ThemeController {
  static final ThemeController _instance = ThemeController._internal();
  factory ThemeController() => _instance;
  ThemeController._internal();

  final ValueNotifier<MaterialColor> themeColor = ValueNotifier(Colors.deepPurple);

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final int? colorValue = prefs.getInt('selectedThemeColor');
    if (colorValue != null) {
      themeColor.value = _getMaterialColorFromValue(colorValue);
    }
  }

  void updateTheme(MaterialColor color) async {
    themeColor.value = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedThemeColor', color.value);
  }

  MaterialColor _getMaterialColorFromValue(int value) {
    return <MaterialColor>[
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.teal
    ].firstWhere((color) => color.value == value, orElse: () => Colors.deepPurple);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Paris'));

  // Initialisation des notifications
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Demande de permission (Android 13+)
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // Chargement du thème
  await ThemeController().loadTheme();

  runApp(const UtilityApp());
}

class UtilityApp extends StatelessWidget {
  const UtilityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MaterialColor>(
      valueListenable: ThemeController().themeColor,
      builder: (context, color, _) {
        return MaterialApp(
          title: 'Utility App',
          theme: ThemeData(primarySwatch: color),
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(), // ✅ Fonctionne maintenant !
        );
      },
    );
  }
}
