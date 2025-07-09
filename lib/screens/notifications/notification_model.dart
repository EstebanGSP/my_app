import 'package:flutter/material.dart';

class CustomNotificationData {
  final int id;
  final String type;
  final DateTime? date;
  final TimeOfDay time;
  final String title;
  final String body;
  final String? soundPath;
  final int? selectedWeekday; // pour hebdomadaire (1 = lundi)
  final int? dayOfMonth;       // pour mensuel (1-31)
  final int? day;              // pour annuel
  final int? month;            // pour annuel

  CustomNotificationData({
    required this.id,
    required this.type,
    required this.date,
    required this.time,
    required this.title,
    required this.body,
    this.soundPath,
    this.selectedWeekday,
    this.dayOfMonth,
    this.day,
    this.month,
  });

  factory CustomNotificationData.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['time'] as String).split(':');
    return CustomNotificationData(
      id: json['id'],
      type: json['type'],
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      title: json['title'],
      body: json['body'],
      soundPath: json['soundPath'],
      selectedWeekday: json['selectedWeekday'],
      dayOfMonth: json['dayOfMonth'],
      day: json['day'],
      month: json['month'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'date': date?.toIso8601String(),
        'time': '${time.hour}:${time.minute}',
        'title': title,
        'body': body,
        'soundPath': soundPath,
        'selectedWeekday': selectedWeekday,
        'dayOfMonth': dayOfMonth,
        'day': day,
        'month': month,
      };
}
