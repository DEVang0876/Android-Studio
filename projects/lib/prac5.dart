import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Prac5 extends StatefulWidget {
  const Prac5({super.key});

  @override
  State<Prac5> createState() => _Prac5State();
}

class _Prac5State extends State<Prac5> {
  late Database database;
  List<Map<String, dynamic>> students = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    initDatabase();
  }

  Future<void> initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'student_records.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE students(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
        );
      },
      version: 1,
    );
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    final List<Map<String, dynamic>> data = await database.query('students');
    setState(() {
      students = data;
    });
  }

  Future<void> addStudent(String name, int age) async {
    await database.insert(
      'students',
      {'name': name, 'age': age},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    fetchStudents();
  }

  Future<void> updateStudent(int id, String name, int age) async {
    await database.update(
      'students',
      {'name': name, 'age': age},
      where: 'id = ?',
      whereArgs: [id],
    );
    fetchStudents();
  }

  Future<void> deleteStudent(int id) async {
    await database.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
    fetchStudents();
  }

  void showUpdateDialog(int id, String currentName, int currentAge) {
    nameController.text = currentName;
    ageController.text = currentAge.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String name = nameController.text;
                String ageText = ageController.text;
                if (name.isNotEmpty && int.tryParse(ageText) != null) {
                  updateStudent(id, name, int.parse(ageText));
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid name or age')),
                  );
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Records'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: ageController,
              decoration: InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && ageController.text.isNotEmpty) {
                  addStudent(nameController.text, int.parse(ageController.text));
                  nameController.clear();
                  ageController.clear();
                }
              },
              child: Text('Add Student'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(students[index]['name']),
                      subtitle: Text('Age: ${students[index]['age']}'),
                      onLongPress: () => showUpdateDialog(
                        students[index]['id'],
                        students[index]['name'],
                        students[index]['age'],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteStudent(students[index]['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}






