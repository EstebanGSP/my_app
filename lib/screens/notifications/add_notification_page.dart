import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class AddNotificationPage extends StatefulWidget {
  const AddNotificationPage({super.key});

  @override
  State<AddNotificationPage> createState() => _AddNotificationPageState();
}

class _AddNotificationPageState extends State<AddNotificationPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  String _frequency = 'Une fois';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _selectedSound;

  final List<String> _frequencies = [
    'Une fois',
    'Journalier',
    'Hebdomadaire',
    'Mensuel',
    'Annuel',
  ];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickSound() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      if (await file.length() <= 5 * 1024 * 1024) {
        setState(() {
          _selectedSound = file;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Le fichier doit faire moins de 5 Mo.")),
        );
      }
    }
  }

  void _scheduleNotification() {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir le titre et le message.")),
      );
      return;
    }

    if (_selectedTime == null || (_frequency == 'Une fois' && _selectedDate == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner une date/heure.")),
      );
      return;
    }

    // TODO : Intégration avec NotificationService + persistence

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notification programmée (simulation).")),
    );

    Navigator.pop(context); // Retour à l'écran précédent
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle notification'),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _frequency,
              items: _frequencies.map((f) {
                return DropdownMenuItem(
                  value: f,
                  child: Text(f),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _frequency = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Fréquence'),
            ),
            const SizedBox(height: 16),
            if (_frequency == 'Une fois') ...[
              ElevatedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(_selectedDate == null
                    ? 'Sélectionner une date'
                    : DateFormat.yMd().format(_selectedDate!)),
              ),
              const SizedBox(height: 12),
            ],
            ElevatedButton.icon(
              onPressed: _pickTime,
              icon: const Icon(Icons.access_time),
              label: Text(_selectedTime == null
                  ? 'Sélectionner une heure'
                  : _selectedTime!.format(context)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickSound,
              icon: const Icon(Icons.music_note),
              label: Text(_selectedSound == null
                  ? 'Choisir un son (.mp3 < 5 sec)'
                  : 'Son sélectionné'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _scheduleNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text('Programmer la notification'),
            )
          ],
        ),
      ),
    );
  }
}
