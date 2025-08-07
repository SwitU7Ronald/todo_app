import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/task_model.dart';
import 'package:todo_app/screens/add_task_screen.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  List<TaskModel> tasks = [];

  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskJsonList = prefs.getStringList('tasks') ?? [];

    setState(() {
      tasks = taskJsonList
          .map((taskJson) {
            final decoded = jsonDecode(taskJson);
            if (decoded is Map<String, dynamic>) {
              return TaskModel.fromMap(decoded);
            } else {
              return null;
            }
          })
          .whereType<TaskModel>()
          .toList();
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> taskJsonList = tasks.map((task) {
      final map = task.toMap();
      return jsonEncode(map);
    }).toList();

    await prefs.setStringList('tasks', taskJsonList);
  }

  void _addNewTask(String title) {
    final newTask = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
      isCompleted: false,
    );

    setState(() {
      tasks.add(newTask);
    });

    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ToDo App"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: tasks.isEmpty
          ? Center(
              child: Text(
                "No Tasks Yet",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(tasks[index].id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment:
                        AlignmentDirectional.centerEnd,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      tasks.removeAt(index);
                    });
                    _saveTasks();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text("Task Deleted"),
                      ),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(tasks[index].title),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(),
            ),
          );

          if (result != null && result is String) {
            _addNewTask(result);
          }
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
