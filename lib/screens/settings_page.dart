import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final List<MaterialColor> colorOptions = [
    Colors.deepPurple,
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  final MaterialColor selectedColor;
  final void Function(MaterialColor) onColorSelected;

  SettingsPage({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisir un thème de couleur',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: colorOptions.map((color) {
                final isSelected = selectedColor == color;
                return GestureDetector(
                  onTap: () => onColorSelected(color),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
