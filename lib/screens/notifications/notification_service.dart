// ✅ notification_service.dart
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:path_provider/path_provider.dart';
import 'notification_model.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> scheduleNotification(CustomNotificationData data, int id) async {
    final tz.TZDateTime scheduledDate = _nextInstance(data);

    final soundFile = data.soundPath != null
        ? await _copySoundToLocalDir(data.soundPath!)
        : null;

    final androidDetails = AndroidNotificationDetails(
      'custom_channel',
      'Notifications Personnalisées',
      channelDescription: 'Canal pour notifications avec son personnalisé',
      importance: Importance.max,
      priority: Priority.high,
      sound: soundFile != null
          ? RawResourceAndroidNotificationSound(soundFile)
          : null,
      playSound: soundFile != null,
    );

    final details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      data.title,
      data.body,
      scheduledDate,
      details,
      matchDateTimeComponents: _getRepeatComponent(data.type),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  tz.TZDateTime _nextInstance(CustomNotificationData data) {
    final now = tz.TZDateTime.now(tz.local);
    final time = data.time;

    switch (data.type) {
      case 'hebdomadaire':
        int weekday = data.selectedWeekday ?? now.weekday;
        tz.TZDateTime scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
        while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
          scheduled = scheduled.add(const Duration(days: 1));
        }
        return scheduled;

      case 'mensuel':
        final day = data.dayOfMonth ?? now.day;
        tz.TZDateTime scheduled = tz.TZDateTime(tz.local, now.year, now.month, day, time.hour, time.minute);
        if (scheduled.isBefore(now)) {
          scheduled = tz.TZDateTime(tz.local, now.year, now.month + 1, day, time.hour, time.minute);
        }
        return scheduled;

      case 'annuel':
        final day = data.day ?? now.day;
        final month = data.month ?? now.month;
        tz.TZDateTime scheduled = tz.TZDateTime(tz.local, now.year, month, day, time.hour, time.minute);
        if (scheduled.isBefore(now)) {
          scheduled = tz.TZDateTime(tz.local, now.year + 1, month, day, time.hour, time.minute);
        }
        return scheduled;

      default:
        return data.date != null
            ? tz.TZDateTime(tz.local, data.date!.year, data.date!.month, data.date!.day, time.hour, time.minute)
            : tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute)
                .add(const Duration(days: 1));
    }
  }

  DateTimeComponents? _getRepeatComponent(String type) {
    switch (type) {
      case 'journalier':
        return DateTimeComponents.time;
      case 'hebdomadaire':
        return DateTimeComponents.dayOfWeekAndTime;
      case 'mensuel':
        return DateTimeComponents.dayOfMonthAndTime;
      case 'annuel':
        return DateTimeComponents.dateAndTime;
      default:
        return null;
    }
  }

  Future<String?> _copySoundToLocalDir(String path) async {
    final File file = File(path);
    if (!await file.exists()) return null;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final File newFile =
        await file.copy('${appDir.path}/${file.uri.pathSegments.last}');
    final fileName = newFile.uri.pathSegments.last.split('.').first;

    return fileName;
  }
}
