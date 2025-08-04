import 'package:flutter/material.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() =>
      _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _taskController =
      TextEditingController();

  void _saveTask() {
    final title = _taskController.text.trim();
    if (title.isNotEmpty) {
      Navigator.pop(context, title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Task"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _taskController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text("Save Task"),
            ),
          ],
        ),
      ),
    );
  }
}
