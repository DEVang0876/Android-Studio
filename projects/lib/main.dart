import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'prac1.dart';
import 'prac2.dart';
import 'prac3.dart';
import 'prac4.dart';
import 'prac5.dart';
import 'prac6.dart';
import 'prac7.dart';
import 'prac8.dart';
import 'prac9.dart';
import 'prac10.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inline Supabase initialization using your project URL and anon key
  const supabaseUrl = 'https://pzwbevmapgmsagtdnxnm.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB6d2Jldm1hcGdtc2FndGRueG5tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwNTU3NzMsImV4cCI6MjA3NDYzMTc3M30.S36sCxlO8SNgnnJkpGAy1XtqJLSWecbHWVGvHoHkX8Q';
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.deepPurple[75],
        appBar: AppBar(
          title: const Text("Practicals 23AIML014"),
          backgroundColor: Colors.green[300],
        ),
        body: Builder(
          // Create a new BuildContext under MaterialApp so Navigator is available
          builder: (context) => Column(
            children: [
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Prac1()));
              }, child: Text("Prac1")),
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Prac2()));
              }, child: Text("Prac2")),
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Prac3()));
              }, child: Text("Prac3")),
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Prac4()));
              }, child: Text("Prac4")),
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Prac5()));
              }, child: Text("Prac5")),
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Prac6()));
              }, child: Text("Prac6")),
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Prac7()));
              }, child: Text("Prac7")),
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Prac8()));
              }, child: Text("Prac8")),
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Prac9()));
              }, child: Text("Prac9")),
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Prac10()));
              }, child: Text("Prac10")),
            ],
          ),
        ),
        // drawer: Drawer(
        //   child: ListTile(
        //     title: Text("home"),
        //     onTap: (){
        //       print("Home clicked");
        //     },
        //   ),
        // ),
      ),
    );
  }
}
