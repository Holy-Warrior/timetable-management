import 'package:flutter/material.dart';
import 'package:timetable/widget_combo_field.dart';

class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  var options = [
    'list value 1',
    'list value 2',
    'list value 3',
    'list value 4',
  ];
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ComboboxField(
          label: 'Combobox Test Field',
          options: options,
          controller: controller,
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              options.add(controller.text);
            });
          },
          child: const Text('Add State'),
        ),
      ],
    );
  }
}
