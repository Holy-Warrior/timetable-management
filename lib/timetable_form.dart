import 'package:flutter/material.dart';
import 'package:timetable/timetable_controller.dart';
import 'package:timetable/widget_combo_field.dart';

class TimetableForm extends StatefulWidget {
  final TimeTable timeTable;
  const TimetableForm({super.key, required this.timeTable});

  @override
  State<TimetableForm> createState() => _TimetableFormState();
}

class _TimetableFormState extends State<TimetableForm> {
  Map<String, dynamic> selected = {};
  Map<String, TextEditingController> controllers = {
    'course': TextEditingController(),
    'teacher': TextEditingController(),
    'day': TextEditingController(),
    'room': TextEditingController(),
    'startTime': TextEditingController(),
    'endTime': TextEditingController(),
    'color': TextEditingController(),
  };

  late final TimeTable tt;
  late final Map<String, List<String>> options;

  @override
  void initState() {
    super.initState();

    tt = widget.timeTable;
    options = tt.getUniqueValues();
  }

  void onSave() {
    final course = controllers['course']!.text;
    final teacher = controllers['teacher']!.text;
    final day = controllers['day']!.text;
    final room = controllers['room']!.text;
    // final startTime = int.tryParse(controllers['startTime']!.text) ?? 0;
    // final endTime = int.tryParse(controllers['endTime']!.text) ?? 0;
    // final color = controllers['color']!.text;

    if (course.isNotEmpty &&
        teacher.isNotEmpty &&
        day.isNotEmpty &&
        room.isNotEmpty) {
      tt.addEntry(
        course,
        teacher,
        day,
        room,
        //  startTime, endTime, color
        0,
        10,
        '#FF5733',
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Timetable Entry'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: onSave)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 4.0,
          children: [
            ComboboxField(
              label: 'Course',
              controller: controllers['course']!,
              options: options['course']!,
            ),
            ComboboxField(
              label: 'Teacher',
              controller: controllers['teacher']!,
              options: options['teacher']!,
            ),
            ComboboxField(
              label: 'Day',
              controller: controllers['day']!,
              options: options['day']!,
            ),
            ComboboxField(
              label: 'Room',
              controller: controllers['room']!,
              options: options['room']!,
            ),
          ],
        ),
      ),
    );
  }
}
