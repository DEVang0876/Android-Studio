import 'package:flutter/material.dart';

class Prac10 extends StatefulWidget {
  const Prac10({super.key});

  @override
  State<Prac10> createState() => _Prac10State();
}
class _Prac10State  extends State<Prac10>
{
  List tasks = [];
  TextEditingController task_input = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Prac10")
      ),body:
    Column(
      children: [
      ],
    ),

    );
  }

}






