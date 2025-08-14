import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

  @override
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
    final pendingTasks = tasks
        .where((task) => !task.isCompleted)
        .toList();
    final completedTasks = tasks
        .where((task) => task.isCompleted)
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Tasks'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTaskList(pendingTasks),
            _buildTaskList(completedTasks),
          ],
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
      ),
    );
  }

  Widget _buildTaskList(List<TaskModel> taskList) {
    if (taskList.isEmpty) {
      return Center(
        child: Text(
          "No Tasks Yet",
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: taskList.length,
        itemBuilder: (context, index) {
          return Slidable(
            key: ValueKey(taskList[index].id),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    setState(() {
                      taskList[index].isCompleted =
                          !taskList[index].isCompleted;
                      final taskIndex = tasks.indexWhere(
                        (task) =>
                            task.id == taskList[index].id,
                      );
                      tasks[taskIndex].isCompleted =
                          taskList[index].isCompleted;
                    });
                    _saveTasks();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          taskList[index].isCompleted
                              ? "Task marked as completed"
                              : "Task marked as pending",
                        ),
                      ),
                    );
                  },
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  icon: Icons.check_circle,
                  label: taskList[index].isCompleted
                      ? 'Unmark'
                      : 'Complete',
                  borderRadius: BorderRadius.circular(12),
                ),
                SlidableAction(
                  onPressed: (context) {
                    setState(() {
                      tasks.removeWhere(
                        (task) =>
                            task.id == taskList[index].id,
                      );
                      taskList.removeAt(index);
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
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  taskList[index].title,
                  style: TextStyle(
                    decoration: taskList[index].isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
