import 'package:flutter/material.dart';

class Prac2 extends StatefulWidget {
  const Prac2({super.key});

  @override
  State<Prac2> createState() => _Prac2State();
}

class _Prac2State extends State<Prac2> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  String _selectedConversion = 'Fahrenheit';

  

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
                labelText: 'Enter temperature in Celsius',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedConversion,
              items: ['Fahrenheit', 'Kelvin', 'Celsius']
                  .map((conversion) => DropdownMenuItem(
                        value: conversion,
                        child: Text(conversion),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedConversion = value!;
                });
              },
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
    double? input = double.tryParse(_controller.text);
    if (input != null) {
      setState(() {
        if (_selectedConversion == 'Fahrenheit') {
          double fahrenheit = (input * 9 / 5) + 32;
          _result = '$input°C = ${fahrenheit.toStringAsFixed(2)}°F';
        } else if (_selectedConversion == 'Kelvin') {
          double kelvin = input + 273.15;
          _result = '$input°C = ${kelvin.toStringAsFixed(2)}K';
        } else {
          _result = '$input°C = $input°C';
        }
      });
    } else {
      setState(() {
        _result = 'Invalid input';
      });
    }
  }
}






