import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'theme_controller.dart'; // 👈 Thème dynamique

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final TextEditingController _amountController = TextEditingController();
  final ThemeController themeController = ThemeController(); // 👈
  List<String> _currencies = [];
  String? _fromCurrency;
  String? _toCurrency;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.frankfurter.app/currencies'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final keys = data.keys.toList()..sort();
        setState(() {
          _currencies = keys;
          _fromCurrency = keys.contains('EUR') ? 'EUR' : keys.first;
          _toCurrency = keys.contains('USD') ? 'USD' : keys.last;
        });
      } else {
        setState(() {
          _result = 'Erreur lors du chargement des devises.';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Erreur réseau lors du chargement des devises : $e';
      });
    }
  }

  Future<void> _convertCurrency() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _result = 'Veuillez entrer un montant valide.';
      });
      return;
    }

    final url =
        'https://api.frankfurter.app/latest?amount=$amount&from=$_fromCurrency&to=$_toCurrency';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final converted = data["rates"][_toCurrency];

        setState(() {
          _result = '${amount.toStringAsFixed(2)} $_fromCurrency = '
              '${converted.toStringAsFixed(2)} $_toCurrency';
        });
      } else {
        setState(() {
          _result = 'Erreur lors de la conversion.';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Erreur réseau : $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = themeController.currentColor;

    if (_currencies.length < 2 || _fromCurrency == null || _toCurrency == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Convertisseur de devises')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Convertisseur de devises',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Montant',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _fromCurrency,
                    decoration: const InputDecoration(labelText: 'De'),
                    items: _currencies
                        .map((currency) => DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _fromCurrency = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _toCurrency,
                    decoration: const InputDecoration(labelText: 'Vers'),
                    items: _currencies
                        .map((currency) => DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _toCurrency = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              onPressed: _convertCurrency,
              child: const Text('Convertir'),
            ),
            const SizedBox(height: 24),
            Text(
              _result,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
