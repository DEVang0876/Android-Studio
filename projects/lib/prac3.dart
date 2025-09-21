import 'package:flutter/material.dart';

class Prac3 extends StatefulWidget {
  const Prac3({super.key});

  @override
  State<Prac3> createState() => _Prac3State();
}
class _Prac3State  extends State<Prac3>
{
  List tasks = [];
  TextEditingController task_input = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Prac3")
      ),body:
    Column(
      children: [
      ],
    ),

    );
  }
}






