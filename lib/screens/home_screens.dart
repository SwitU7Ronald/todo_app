import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/screens/add_task_screen.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  List<String> tasks = [];

  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTasks = prefs.getStringList('tasks') ?? [];
    setState(() {
      tasks = storedTasks;
    });
  }

  Future<void> _saveTask() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tasks', tasks);
  }

  void _addNewTask(String newTask) {
    setState(() {
      tasks.add(newTask);
    });
    _saveTask();
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
                  key: Key(tasks[index]),
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
                    _saveTask();
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
                      title: Text(tasks[index]),
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
