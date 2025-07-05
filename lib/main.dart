import 'package:flutter/material.dart';
import 'package:timetable/home.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Time Table')),
        body: Home(),
      ),
    );
  }
}
