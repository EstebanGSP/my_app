import 'package:flutter/material.dart';
import 'currency_converter.dart';
import 'countdown_timer.dart';
import 'custom_notifications.dart';
import 'calculator_page.dart';
import 'settings_page.dart';
import 'theme_controller.dart';
import 'widget/widget_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ThemeController themeController = ThemeController();

  List<Widget> getScreens() {
    return [
      const CurrencyConverter(),
      const CountdownTimer(),
      const CustomNotifications(),
      const CalculatorPage(),
      const WidgetPage(),
      SettingsPage(
        selectedColor: themeController.currentColor,
        onColorSelected: (color) {
          themeController.setColor(color);
          setState(() {}); // Rafraîchir l'UI si thème change
        },
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = themeController.currentColor;
    final screens = getScreens();

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: color,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange),
            label: 'Taux de change',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Minuteur',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculatrice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Widgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
