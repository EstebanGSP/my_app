import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/screens/notifications/notification_controller.dart';
import 'package:my_app/screens/notifications/notification_form.dart';
import 'package:my_app/screens/notifications/notification_model.dart';
import 'package:my_app/screens/theme_controller.dart';

class CustomNotifications extends StatelessWidget {
  const CustomNotifications({super.key});

  String _getTypeLabel(CustomNotificationData data, BuildContext context) {
    final String timeStr = data.time.format(context);

    switch (data.type) {
      case 'une fois':
        return "Le ${_formatDate(data.date)} à $timeStr";
      case 'journalier':
        return "Chaque jour à $timeStr";
      case 'hebdomadaire':
        return "Chaque semaine le ${_weekdayName(data.date!.weekday)} à $timeStr";
      case 'mensuel':
        return "Chaque mois le ${data.date!.day} à $timeStr";
      case 'annuel':
        return "Chaque année le ${_formatDate(data.date, short: true)} à $timeStr";
      default:
        return "$timeStr";
    }
  }

  String _formatDate(DateTime? date, {bool short = false}) {
    if (date == null) return '';
    return short
        ? "${date.day}/${date.month}"
        : "${date.day}/${date.month}/${date.year}";
  }

  String _weekdayName(int weekday) {
    const List<String> weekdays = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];
    return weekdays[(weekday - 1) % 7];
  }

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController();
    final primaryColor = themeController.currentColor;

    return ChangeNotifierProvider(
      create: (_) => NotificationController()..loadNotifications(),
      child: Consumer<NotificationController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Notifications personnalisées'),
              backgroundColor: primaryColor,
            ),
            body: controller.notifications.isEmpty
                ? const Center(child: Text("Aucune notification programmée"))
                : ListView.builder(
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = controller.notifications[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(notification.title),
                          subtitle: Text(_getTypeLabel(notification, context)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                controller.removeNotification(notification),
                          ),
                        ),
                      );
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationForm(
                      onSave: (data) {
                        Provider.of<NotificationController>(context, listen: false)
                            .addNotification(data);
                      },
                    ),
                  ),
                );
              },
              backgroundColor: primaryColor,
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
