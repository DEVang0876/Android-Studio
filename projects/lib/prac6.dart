import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class Prac6 extends StatelessWidget {
  const Prac6({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      
    );
  }
}

