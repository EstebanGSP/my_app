import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'notification_model.dart';
import 'package:my_app/screens/theme_controller.dart'; // thème

class NotificationForm extends StatefulWidget {
  final Function(CustomNotificationData) onSave;

  const NotificationForm({super.key, required this.onSave});

  @override
  State<NotificationForm> createState() => _NotificationFormState();
}

class _NotificationFormState extends State<NotificationForm> {
  final ThemeController themeController = ThemeController();

  String _type = 'une fois';
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;
  int? _selectedWeekday; // hebdomadaire
  int? _selectedDayOfMonth; // mensuel
  int? _selectedDayAnnual; // annuel
  int? _selectedMonthAnnual; // annuel

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String? _soundPath;

  final List<String> _types = [
    'une fois',
    'journalier',
    'hebdomadaire',
    'mensuel',
    'annuel',
  ];

  final List<String> _weekdays = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche'
  ];

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickSound() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _soundPath = result.files.first.path;
      });
    }
  }

  void _submitForm() {
    if (_selectedTime == null ||
        _titleController.text.isEmpty ||
        _bodyController.text.isEmpty ||
        (_type == 'une fois' && _selectedDate == null) ||
        (_type == 'hebdomadaire' && _selectedWeekday == null) ||
        (_type == 'mensuel' && _selectedDayOfMonth == null) ||
        (_type == 'annuel' &&
            (_selectedDayAnnual == null || _selectedMonthAnnual == null))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci de remplir tous les champs obligatoires')),
      );
      return;
    }

    // Calcul de la date à partir des champs spéciaux
    DateTime? computedDate;

    if (_type == 'hebdomadaire') {
      final now = DateTime.now();
      int currentWeekday = now.weekday;
      int daysDiff = (_selectedWeekday! - currentWeekday + 7) % 7;
      computedDate = now.add(Duration(days: daysDiff));
    } else if (_type == 'mensuel') {
      final now = DateTime.now();
      computedDate = DateTime(now.year, now.month, _selectedDayOfMonth!);
      if (computedDate.isBefore(now)) {
        computedDate = DateTime(now.year, now.month + 1, _selectedDayOfMonth!);
      }
    } else if (_type == 'annuel') {
      final now = DateTime.now();
      computedDate = DateTime(now.year, _selectedMonthAnnual!, _selectedDayAnnual!);
      if (computedDate.isBefore(now)) {
        computedDate = DateTime(now.year + 1, _selectedMonthAnnual!, _selectedDayAnnual!);
      }
    } else {
      computedDate = _selectedDate;
    }

    final data = CustomNotificationData(
      id: DateTime.now().millisecondsSinceEpoch,
      type: _type,
      time: _selectedTime!,
      date: computedDate,
      title: _titleController.text,
      body: _bodyController.text,
      soundPath: _soundPath,
    );

    widget.onSave(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final color = themeController.currentColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer une notification"),
        backgroundColor: color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Type de notification :"),
            DropdownButton<String>(
              value: _type,
              isExpanded: true,
              items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (value) => setState(() => _type = value!),
            ),
            const SizedBox(height: 16),

            if (_type == 'une fois') ...[
              const Text("Date :"),
              TextButton(
                onPressed: _pickDate,
                child: Text(
                  _selectedDate != null
                      ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                      : "Choisir une date",
                ),
              ),
            ],

            if (_type == 'hebdomadaire') ...[
              const Text("Jour de la semaine :"),
              DropdownButton<int>(
                value: _selectedWeekday,
                isExpanded: true,
                hint: const Text("Choisir un jour"),
                items: List.generate(
                  _weekdays.length,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text(_weekdays[index]),
                  ),
                ),
                onChanged: (val) => setState(() => _selectedWeekday = val),
              ),
            ],

            if (_type == 'mensuel') ...[
              const Text("Jour du mois :"),
              DropdownButton<int>(
                value: _selectedDayOfMonth,
                isExpanded: true,
                hint: const Text("Choisir un jour (1 à 31)"),
                items: List.generate(
                  31,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text("${index + 1}"),
                  ),
                ),
                onChanged: (val) => setState(() => _selectedDayOfMonth = val),
              ),
            ],

            if (_type == 'annuel') ...[
              const Text("Jour :"),
              DropdownButton<int>(
                value: _selectedDayAnnual,
                isExpanded: true,
                hint: const Text("Choisir le jour"),
                items: List.generate(
                  31,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text("${index + 1}"),
                  ),
                ),
                onChanged: (val) => setState(() => _selectedDayAnnual = val),
              ),
              const SizedBox(height: 10),
              const Text("Mois :"),
              DropdownButton<int>(
                value: _selectedMonthAnnual,
                isExpanded: true,
                hint: const Text("Choisir le mois"),
                items: List.generate(
                  12,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text("${index + 1}"),
                  ),
                ),
                onChanged: (val) => setState(() => _selectedMonthAnnual = val),
              ),
            ],

            const Text("Heure :"),
            TextButton(
              onPressed: _pickTime,
              child: Text(
                _selectedTime != null ? _selectedTime!.format(context) : "Choisir l'heure",
              ),
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Titre de la notification"),
            ),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: "Message de la notification"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickSound,
              icon: const Icon(Icons.music_note),
              label: Text(
                _soundPath != null ? "Son sélectionné ✅" : "Choisir un son (MP3 < 5s)",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(backgroundColor: color),
              child: const Text("Créer"),
            ),
          ],
        ),
      ),
    );
  }
}
