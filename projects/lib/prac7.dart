import 'package:flutter/material.dart';

class Prac7 extends StatefulWidget {
  const Prac7({super.key});

  @override
  State<Prac7> createState() => _Prac7State();
}
class _Prac7State  extends State<Prac7>
{
  List tasks = [];
  TextEditingController task_input = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Prac7")
      ),body:
    Column(
      children: [
      ],
    ),

    );
  }

  
}






