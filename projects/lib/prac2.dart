import 'package:flutter/material.dart';

class Prac2 extends StatefulWidget {
  const Prac2({super.key});

  @override
  State<Prac2> createState() => _Prac2State();
}

class _Prac2State extends State<Prac2> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  String _from = 'Celsius';
  String _to = 'Fahrenheit';

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Temperature Converter'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter value',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _from,
                    decoration: const InputDecoration(labelText: 'From', border: OutlineInputBorder()),
                    items: const ['Celsius', 'Fahrenheit', 'Kelvin']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) => setState(() => _from = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _to,
                    decoration: const InputDecoration(labelText: 'To', border: OutlineInputBorder()),
                    items: const ['Celsius', 'Fahrenheit', 'Kelvin']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) => setState(() => _to = v!),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convertTemperature,
              child: Text('Convert'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _result,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
  void _convertTemperature() {
    final input = double.tryParse(_controller.text.trim());
    if (input == null) {
      setState(() => _result = 'Please enter a valid number');
      return;
    }

    double inCelsius;
    // Convert input to Celsius
    switch (_from) {
      case 'Fahrenheit':
        inCelsius = (input - 32) * 5 / 9;
        break;
      case 'Kelvin':
        inCelsius = input - 273.15;
        break;
      default:
        inCelsius = input;
    }

    double out;
    String unitSuffix;
    switch (_to) {
      case 'Fahrenheit':
        out = (inCelsius * 9 / 5) + 32;
        unitSuffix = '°F';
        break;
      case 'Kelvin':
        out = inCelsius + 273.15;
        unitSuffix = 'K';
        break;
      default:
        out = inCelsius;
        unitSuffix = '°C';
    }

    setState(() => _result = '${input.toStringAsFixed(2)} $_from = ${out.toStringAsFixed(2)} $unitSuffix');
  }
}






