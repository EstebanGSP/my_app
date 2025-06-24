import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'timer_service.dart';
import 'theme_controller.dart'; // 👈 Import unique ici

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({super.key});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  final TimerService timerService = TimerService();
  final ThemeController themeController = ThemeController(); // 👈
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    timerService.loadTimers().then((_) => setState(() {}));
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _scheduleNotification(String title, DateTime scheduledDate, int id) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Minuteur terminé ⏰',
      '"$title" est arrivé à son terme.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'timer_channel_v2',
          'Minuteurs',
          channelDescription: 'Notifications de fin de minuteurs',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  void _deleteTimer(int index) {
    final timer = timerService.timers[index];
    _cancelNotification(timer.id);
    setState(() {
      timerService.removeTimer(index);
    });
  }

  void _showAddTimerDialog() async {
    final TextEditingController _titleController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un minuteur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDate),
                    );
                    if (time != null) {
                      selectedDate = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        time.hour,
                        time.minute,
                      );
                    }
                  }
                },
                child: const Text('Choisir date et heure'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  final newTimer = TimerItem(
                    title: _titleController.text,
                    startTime: DateTime.now(),
                    endTime: selectedDate,
                  );
                  setState(() {
                    timerService.addTimer(newTimer);
                  });
                  _scheduleNotification(newTimer.title, newTimer.endTime, newTimer.id);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  double _getProgress(TimerItem timer) {
    final totalDuration = timer.endTime.difference(timer.startTime).inSeconds;
    final elapsed = DateTime.now().difference(timer.startTime).inSeconds;
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  void _openDetailPage(TimerItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimerDetailPage(timer: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timers = timerService.timers;
    final color = themeController.currentColor;

    return Scaffold(
      body: timers.isEmpty
          ? const Center(child: Text('Aucun minuteur pour le moment.'))
          : ListView.builder(
              itemCount: timers.length,
              itemBuilder: (context, index) {
                final item = timers[index];
                final progress = _getProgress(item);

                return GestureDetector(
                  onTap: () => _openDetailPage(item),
                  child: Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(item.title,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () => _deleteTimer(index),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: progress,
                            color: color,
                            backgroundColor: color.withOpacity(0.2),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Fin : ${DateFormat('yyyy-MM-dd – HH:mm').format(item.endTime)}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTimerDialog,
        backgroundColor: color,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TimerDetailPage extends StatelessWidget {
  final TimerItem timer;

  const TimerDetailPage({super.key, required this.timer});

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController(); // 👈 accès au thème ici
    final color = themeController.currentColor;

    final now = DateTime.now();
    final remaining = timer.endTime.difference(now);
    final formattedEnd = DateFormat('yyyy-MM-dd – HH:mm').format(timer.endTime);
    final formattedStart = DateFormat('yyyy-MM-dd – HH:mm').format(timer.startTime);

    final total = timer.endTime.difference(timer.startTime).inSeconds;
    final elapsed = now.difference(timer.startTime).inSeconds;
    final progress = (elapsed / total).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: Text(timer.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timer.title,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                "Ajouté le : $formattedStart",
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                color: color,
                backgroundColor: color.withOpacity(0.2),
              ),
              const SizedBox(height: 24),
              Text("Fin prévue : $formattedEnd", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                "Temps restant : ${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
