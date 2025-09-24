import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Prac5 extends StatefulWidget {
  const Prac5({super.key});

  @override
  State<Prac5> createState() => _Prac5State();
}

class _Prac5State extends State<Prac5> {
  Database? database;
  List<Map<String, dynamic>> students = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'student_records.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE students(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER)',
        );
      },
      version: 1,
    );
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    if (database == null) return;
    final List<Map<String, dynamic>> data = await database!.query('students');
    setState(() {
      students = data;
    });
  }

  Future<void> addStudent(String name, int age) async {
    if (database == null) return;
    await database!.insert(
      'students',
      {'name': name, 'age': age},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    fetchStudents();
  }

  Future<void> updateStudent(int id, String name, int age) async {
    if (database == null) return;
    await database!.update(
      'students',
      {'name': name, 'age': age},
      where: 'id = ?',
      whereArgs: [id],
    );
    fetchStudents();
  }

  Future<void> deleteStudent(int id) async {
    if (database == null) return;
    await database!.delete(
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
      context: this.context, // Fixed the context issue
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
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && ageController.text.isNotEmpty) {
                  updateStudent(id, nameController.text, int.tryParse(ageController.text) ?? 0);
                  nameController.clear();
                  ageController.clear();
                  Navigator.of(context).pop();
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
                  addStudent(nameController.text, int.tryParse(ageController.text) ?? 0);
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
                      title: Text(students[index]['name'] ?? ''),
                      subtitle: Text('Age: ${students[index]['age'] ?? ''}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteStudent(students[index]['id']),
                      ),
                      onLongPress: () => showUpdateDialog(
                        students[index]['id'],
                        students[index]['name'],
                        students[index]['age'],
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
