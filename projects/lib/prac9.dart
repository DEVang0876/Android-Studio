import 'package:flutter/material.dart';

class Prac9 extends StatefulWidget {
  const Prac9({super.key});

  @override
  State<Prac9> createState() => _Prac9State();
}
class _Prac9State  extends State<Prac9>
{
  List tasks = [];
  TextEditingController task_input = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Prac9")
      ),body:
    Column(
      children: [
      ],
    ),

    );
  }

}






