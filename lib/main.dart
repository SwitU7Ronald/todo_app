import 'package:flutter/material.dart';
import 'package:todo_app/screens/home_screens.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ("ToDo App"),
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: HomeScreens(),
    );
  }
}
