import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_model.dart';
import 'notification_service.dart';

class NotificationController extends ChangeNotifier {
  final List<CustomNotificationData> _notifications = [];

  List<CustomNotificationData> get notifications => List.unmodifiable(_notifications);

  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList('custom_notifications');

    if (stored != null) {
      _notifications.clear();
      _notifications.addAll(stored.map((jsonStr) =>
          CustomNotificationData.fromJson(json.decode(jsonStr))));
      notifyListeners();
    }
  }

  Future<void> addNotification(CustomNotificationData data) async {
    _notifications.add(data);
    await _saveAll();
    await NotificationService().scheduleNotification(data, data.id);
    notifyListeners();
  }

  Future<void> removeNotification(CustomNotificationData data) async {
    _notifications.removeWhere((n) => n.id == data.id);
    await _saveAll();
    await NotificationService().cancelNotification(data.id);
    notifyListeners();
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList =
        _notifications.map((n) => json.encode(n.toJson())).toList();
    await prefs.setStringList('custom_notifications', jsonList);
  }
}
