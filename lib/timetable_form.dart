import 'package:flutter/material.dart';
import 'package:timetable/models/timetable_model.dart';
import 'package:timetable/timetable_controller.dart';
import 'package:timetable/widget_combo_field.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TimetableForm extends StatefulWidget {
  final TimeTable timeTable;
  final TimetableEntry? entryToEdit;
  final String? courseName;
  final String? teacherName;

  const TimetableForm({
    super.key, 
    required this.timeTable, 
    this.entryToEdit,
    this.courseName,
    this.teacherName,
  });

  @override
  State<TimetableForm> createState() => _TimetableFormState();
}

class _TimetableFormState extends State<TimetableForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _courseController;
  late TextEditingController _teacherController;
  late TextEditingController _roomController;
  
  String _selectedDay = 'Monday';
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  Color _selectedColor = Colors.indigo;

  final List<String> _daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _courseController = TextEditingController(text: widget.courseName ?? '');
    _teacherController = TextEditingController(text: widget.teacherName ?? '');
    _roomController = TextEditingController(text: widget.entryToEdit?.room ?? '');
    
    if (widget.entryToEdit != null) {
      _selectedDay = widget.entryToEdit!.day;
      _startTime = TimeOfDay(
        hour: widget.entryToEdit!.startTime ~/ 60,
        minute: widget.entryToEdit!.startTime % 60,
      );
      _endTime = TimeOfDay(
        hour: widget.entryToEdit!.endTime ~/ 60,
        minute: widget.entryToEdit!.endTime % 60,
      );
      _selectedColor = widget.entryToEdit!.color;
    }
  }

  @override
  void dispose() {
    _courseController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate() && _startTime != null && _endTime != null) {
      final startMin = _startTime!.hour * 60 + _startTime!.minute;
      final endMin = _endTime!.hour * 60 + _endTime!.minute;


      final entry = TimetableEntry(
        id: widget.entryToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        day: _selectedDay,
        room: _roomController.text.trim(),
        startTime: startMin,
        endTime: endMin,
        color: _selectedColor,
      );

      widget.timeTable.addOrUpdateEntry(
        courseName: _courseController.text.trim(),
        teacher: _teacherController.text.trim(),
        entry: entry,
        entryIdToUpdate: widget.entryToEdit?.id,
      );

      Navigator.pop(context);
    } else if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end times')),
      );
    }
  }

  void _onDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class?'),
        content: const Text('Are you sure you want to remove this class from your schedule?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              widget.timeTable.deleteEntry(widget.courseName!, widget.teacherName!, widget.entryToEdit!.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close form
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickColor() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() => _selectedColor = color);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entryToEdit != null;
    final options = widget.timeTable.getUniqueValues();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Class' : 'Add New Class'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _onDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ComboboxField(
                label: 'Course Name',
                controller: _courseController,
                options: options['course'] ?? [],
              ),
              const SizedBox(height: 16),
              ComboboxField(
                label: 'Teacher Name',
                controller: _teacherController,
                options: options['teacher'] ?? [],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedDay,
                decoration: const InputDecoration(
                  labelText: 'Day of Week',
                  border: OutlineInputBorder(),
                ),
                items: _daysOfWeek.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                onChanged: (val) => setState(() => _selectedDay = val!),
              ),
              const SizedBox(height: 16),
              ComboboxField(
                label: 'Room / Location',
                controller: _roomController,
                options: options['room'] ?? [],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _TimePickerField(
                      label: 'Start Time',
                      time: _startTime,
                      onTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: _startTime ?? const TimeOfDay(hour: 9, minute: 0));
                        if (picked != null) setState(() => _startTime = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TimePickerField(
                      label: 'End Time',
                      time: _endTime,
                      onTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: _endTime ?? const TimeOfDay(hour: 10, minute: 0));
                        if (picked != null) setState(() => _endTime = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ListTile(
                title: const Text('Theme Color'),
                subtitle: const Text('Pick a color for this course'),
                trailing: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12),
                  ),
                ),
                onTap: _pickColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isEditing ? 'Update Schedule' : 'Save to Schedule', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  const _TimePickerField({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(
          time != null ? time!.format(context) : 'Select',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
