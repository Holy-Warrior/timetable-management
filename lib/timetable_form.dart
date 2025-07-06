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
    'room': TextEditingController(),
    'startTime': TextEditingController(),
    'endTime': TextEditingController(),
    'color': TextEditingController(),
  };
  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  Map<String, String> dropDownVariables = {'day': 'Monday'};

  late final TimeTable tt;
  late final Map<String, List<String>> options;

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final Map<String, Color> colorOptions = {
    'Red': Colors.red,
    'Green': Colors.green,
    'Blue': Colors.blue,
    'Orange': Colors.orange,
    'Purple': Colors.purple,
    'Teal': Colors.teal,
    'Amber': Colors.amber,
    'Pink': Colors.pink,
    'Brown': Colors.brown,
  };
  String selectedColorName = 'Red';

  @override
  void initState() {
    super.initState();

    tt = widget.timeTable;
    options = tt.getUniqueValues();
  }

  void onSave() {
    String capitalize(String s) =>
        s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).toLowerCase() : s;

    final course = capitalize(controllers['course']!.text.trim());
    final teacher = capitalize(controllers['teacher']!.text.trim());
    final room = capitalize(controllers['room']!.text.trim());
    final int? startMinutes =
        startTime != null ? startTime!.hour * 60 + startTime!.minute : null;
    final int? endMinutes =
        endTime != null ? endTime!.hour * 60 + endTime!.minute : null;
    final color = colorOptions[selectedColorName]!;
    final colorHex =
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

    if (course.isNotEmpty &&
        teacher.isNotEmpty &&
        room.isNotEmpty &&
        startMinutes != null &&
        endMinutes != null) {
      tt.addEntry(
        course,
        teacher,
        dropDownVariables['day']!,
        room,
        startMinutes,
        endMinutes,
        colorHex,
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
    }
  }

  Widget buildDropdown({
    required String label,
    required List<String> options,
    required String selectedValue,
  }) {
    // adding label
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          items:
              options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              if (label == 'Day') {
                dropDownVariables['day'] = newValue!;
              } else {
                selected[label] = newValue!;
                controllers[label]!.text = newValue;
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Timetable Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            buildDropdown(
              label: 'Day',
              options: daysOfWeek,
              selectedValue: dropDownVariables['day']!,
            ),
            ComboboxField(
              label: 'Room',
              controller: controllers['room']!,
              options: options['room']!,
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: startTime ?? TimeOfDay(hour: 8, minute: 0),
                      );
                      if (picked != null) {
                        setState(() {
                          startTime = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: 'Start Time'),
                      child: Text(
                        startTime != null
                            ? startTime!.format(context)
                            : 'Select Time',
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: endTime ?? TimeOfDay(hour: 9, minute: 0),
                      );
                      if (picked != null) {
                        setState(() {
                          endTime = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: 'End Time'),
                      child: Text(
                        endTime != null
                            ? endTime!.format(context)
                            : 'Select Time',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedColorName,
              decoration: const InputDecoration(labelText: 'Color'),
              items:
                  colorOptions.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: entry.value,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(entry.key),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (colorName) {
                setState(() {
                  selectedColorName = colorName!;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onSave,
              child: const Text('Save'),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(48)),
            ),
          ],
        ),
      ),
    );
  }
}
