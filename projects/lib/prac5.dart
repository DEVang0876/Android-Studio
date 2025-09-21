import 'package:flutter/material.dart';

class Prac5 extends StatefulWidget {
  const Prac5({super.key});

  @override
  State<Prac5> createState() => _Prac5State();
}
class _Prac5State  extends State<Prac5>
{
  List tasks = [];
  TextEditingController task_input = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Prac5")
      ),body:
    Column(
      children: [
      ],
    ),

    );
  }

}






