import 'package:flutter/material.dart';

class Prac3 extends StatefulWidget {
  const Prac3({super.key});

  @override
  State<Prac3> createState() => _Prac3State();
}

class _Prac3State extends State<Prac3> {
  final List<_Todo> tasks = [];
  final TextEditingController taskController = TextEditingController();

  void addTask() {
    final text = taskController.text.trim();
    if (text.isNotEmpty) {
      setState(() => tasks.insert(0, _Todo(text)));
      taskController.clear();
    }
  }

  void deleteTask(int index) {
    final removed = tasks.removeAt(index);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${removed.title}"'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => setState(() => tasks.insert(index, removed)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic TODO App'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Task',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: addTask, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text('No tasks yet. Add one!'))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final t = tasks[index];
                        return Dismissible(
                          key: ValueKey(t.id),
                          background: Container(color: Colors.redAccent),
                          onDismissed: (_) => deleteTask(index),
                          child: CheckboxListTile(
                            value: t.done,
                            title: Text(
                              t.title,
                              style: TextStyle(
                                decoration: t.done ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            onChanged: (v) => setState(() => t.done = v ?? false),
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

class _Todo {
  _Todo(this.title);
  final String id = UniqueKey().toString();
  final String title;
  bool done = false;
}






