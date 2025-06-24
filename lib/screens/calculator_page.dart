import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _result = '0';

  final List<String> _buttons = [
    '(', ')', '%', 'AC',
    'sin', 'cos', 'tan', '÷',
    'ln', 'log', '√', '×',
    '7', '8', '9', '-',
    '4', '5', '6', '+',
    '1', '2', '3', '=',
    'π', '0', '.', '^',
  ];

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'AC') {
        _expression = '';
        _result = '0';
      } else if (value == '=') {
        _calculateResult();
      } else if (value == 'π') {
        _expression += '3.1416';
      } else if (value == '√') {
        _expression += 'sqrt(';
      } else if (value == 'ln') {
        _expression += 'ln(';
      } else if (value == 'log') {
        _expression += 'log(';
      } else if (value == 'sin' || value == 'cos' || value == 'tan') {
        _expression += '$value(';
      } else if (value == '÷') {
        _expression += '/';
      } else if (value == '×') {
        _expression += '*';
      } else {
        _expression += value;
      }
    });
  }

  void _calculateResult() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      _result = eval.toString();
    } catch (e) {
      _result = 'Erreur';
    }
  }

  Widget _buildButton(String label, double buttonWidth, double buttonHeight, Color primaryColor) {
    final isOperator = ['÷', '×', '-', '+', '=', '^'].contains(label);

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: isOperator ? Colors.white : primaryColor,
          backgroundColor: isOperator ? primaryColor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          padding: const EdgeInsets.all(0),
        ),
        onPressed: () => _onButtonPressed(label),
        child: Text(
          label,
          style: TextStyle(
            fontSize: buttonHeight * 0.28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSpacing = 10.0;
    final numColumns = 4;
    final numRows = (_buttons.length / numColumns).ceil();

    // ✅ Utiliser la bonne couleur dynamique du thème
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculatrice'),
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final topPanelHeight = availableHeight * 0.25;
            final gridHeight = availableHeight - topPanelHeight;
            final buttonHeight = (gridHeight - ((numRows + 1) * buttonSpacing)) / numRows;
            final buttonWidth = (screenWidth - ((numColumns + 1) * buttonSpacing)) / numColumns;

            return Column(
              children: [
                Container(
                  color: primaryColor.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  width: double.infinity,
                  height: topPanelHeight,
                  alignment: Alignment.bottomRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _expression,
                        style: const TextStyle(fontSize: 22, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: gridHeight,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: buttonSpacing,
                      right: buttonSpacing,
                      top: buttonSpacing,
                    ),
                    child: GridView.count(
                      crossAxisCount: numColumns,
                      mainAxisSpacing: buttonSpacing,
                      crossAxisSpacing: buttonSpacing,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: buttonWidth / buttonHeight,
                      children: _buttons
                          .map((label) =>
                              _buildButton(label, buttonWidth, buttonHeight, primaryColor))
                          .toList(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
