import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TimerItem {
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final int id; // ✅ Ajout d’un ID unique pour gérer les notifications

  TimerItem({
    required this.title,
    required this.startTime,
    required this.endTime,
    int? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch; // génère un ID unique si non fourni

  Map<String, dynamic> toJson() => {
        'title': title,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'id': id,
      };

  factory TimerItem.fromJson(Map<String, dynamic> json) => TimerItem(
        title: json['title'],
        startTime: DateTime.parse(json['startTime']),
        endTime: DateTime.parse(json['endTime']),
        id: json['id'],
      );
}

class TimerService {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  final List<TimerItem> _timers = [];

  List<TimerItem> get timers => _timers;

  Future<void> saveTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        _timers.map((t) => t.toJson()).toList();
    await prefs.setString('timers', jsonEncode(jsonList));
  }

  Future<void> loadTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('timers');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      _timers
        ..clear()
        ..addAll(jsonList.map((e) => TimerItem.fromJson(e)).toList());

      // ✅ Supprimer les minuteurs expirés automatiquement
      _timers.removeWhere((t) => t.endTime.isBefore(DateTime.now()));
      await saveTimers();
    }
  }

  void addTimer(TimerItem item) {
    _timers.add(item);
    saveTimers();
  }

  void removeTimer(int index) {
    if (index >= 0 && index < _timers.length) {
      _timers.removeAt(index);
      saveTimers();
    }
  }

  void clearTimers() {
    _timers.clear();
    saveTimers();
  }
}
