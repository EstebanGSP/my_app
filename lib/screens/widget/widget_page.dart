import 'package:flutter/material.dart';
import '../theme_controller.dart';

class WidgetPage extends StatefulWidget {
  const WidgetPage({super.key});

  @override
  State<WidgetPage> createState() => _WidgetPageState();
}

class _WidgetPageState extends State<WidgetPage> {
  final List<_TextElement> _texts = [];

  void _addText() {
    setState(() {
      _texts.add(_TextElement(
        key: UniqueKey(),
        offset: const Offset(100, 100),
        text: "Nouveau texte",
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = ThemeController().currentColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Éditeur de widgets"),
        backgroundColor: color,
        actions: [
          IconButton(
            onPressed: _addText,
            icon: const Icon(Icons.text_fields),
            tooltip: "Ajouter un texte",
          )
        ],
      ),
      body: Stack(
        children: [
          // Zone d’édition
          Container(color: Colors.grey[100]),
          // Tous les textes posés
          ..._texts,
        ],
      ),
    );
  }
}

// 🔧 Widget interne pour gérer un texte déplaçable
class _TextElement extends StatefulWidget {
  final Offset offset;
  final String text;

  const _TextElement({super.key, required this.offset, required this.text});

  @override
  State<_TextElement> createState() => _TextElementState();
}

class _TextElementState extends State<_TextElement> {
  late Offset _position;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _position = widget.offset;
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
          child: IntrinsicWidth(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(border: InputBorder.none),
              style: const TextStyle(fontSize: 18),
              maxLines: null,
            ),
          ),
        ),
      ),
    );
  }
}
