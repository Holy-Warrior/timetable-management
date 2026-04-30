import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetable/timetable_controller.dart';
import 'package:timetable/models/timetable_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<TimeTable>(
        builder: (context, tt, _) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Notifications'),
                      subtitle: Text('Receive alerts ${tt.notificationOffset} minutes before class starts'),
                      value: tt.notificationsEnabled,
                      onChanged: (bool value) {
                        tt.toggleNotifications(value);
                      },
                    ),
                    if (tt.notificationsEnabled) ...[
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Alert Time'),
                        subtitle: const Text('How early to send the notification'),
                        trailing: DropdownButton<int>(
                          value: tt.notificationOffset,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('At time of class')),
                            DropdownMenuItem(value: 5, child: Text('5 min before')),
                            DropdownMenuItem(value: 10, child: Text('10 min before')),
                            DropdownMenuItem(value: 15, child: Text('15 min before')),
                            DropdownMenuItem(value: 30, child: Text('30 min before')),
                            DropdownMenuItem(value: 60, child: Text('1 hour before')),
                          ],
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              tt.setNotificationOffset(newValue);
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('Appearance'),
                  subtitle: const Text('Change the app theme'),
                  trailing: DropdownButton<ThemeMode>(
                    value: tt.themeMode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                      DropdownMenuItem(value: ThemeMode.system, child: Text('Automatic')),
                    ],
                    onChanged: (ThemeMode? newValue) {
                      if (newValue != null) {
                        tt.setThemeMode(newValue);
                      }
                    },
                  ),
                ),
              ),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.file_upload_outlined),
                      title: const Text('Export Schedules'),
                      subtitle: const Text('Share your schedules as a file'),
                      onTap: () {
                        if (tt.courses.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No schedules to export.')),
                          );
                          return;
                        }
                        showDialog(
                          context: context,
                          builder: (_) => ExportSelectionDialog(allCourses: tt.courses),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.file_download_outlined),
                      title: const Text('Import Schedules'),
                      subtitle: const Text('Share a .mysched file to this app'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('How to Import'),
                            content: const Text(
                              'To import a schedule:\n\n'
                              '1. Locate the .mysched file in your file manager or messages.\n'
                              '2. Tap "Share" on the file.\n'
                              '3. Select "My Schedules" from the share sheet.\n\n'
                              'The app will automatically detect and import it.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Got it'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ExportItem {
  final Course course;
  final TimetableEntry entry;
  bool isSelected = true;
  ExportItem(this.course, this.entry);
}

class DayGroup {
  final String day;
  final List<ExportItem> items;
  bool isSelected = true;
  DayGroup(this.day, this.items);
}

class ExportSelectionDialog extends StatefulWidget {
  final List<Course> allCourses;

  const ExportSelectionDialog({super.key, required this.allCourses});

  @override
  State<ExportSelectionDialog> createState() => _ExportSelectionDialogState();
}

class _ExportSelectionDialogState extends State<ExportSelectionDialog> {
  List<DayGroup> dayGroups = [];

  @override
  void initState() {
    super.initState();
    Map<String, List<ExportItem>> grouped = {};
    for (var c in widget.allCourses) {
      for (var e in c.entries) {
        if (!grouped.containsKey(e.day)) {
          grouped[e.day] = [];
        }
        grouped[e.day]!.add(ExportItem(c, e));
      }
    }
    
    final List<String> weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    List<String> sortedDays = grouped.keys.toList()
      ..sort((a, b) {
        int indexA = weekDays.indexOf(a);
        int indexB = weekDays.indexOf(b);
        return indexA.compareTo(indexB);
      });

    for (var day in sortedDays) {
      dayGroups.add(DayGroup(day, grouped[day]!));
    }
  }

  String _formatTime(BuildContext context, int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final time = TimeOfDay(hour: hour, minute: minute);
    return time.format(context);
  }

  void _export() async {
    List<Course> coursesToExport = [];
    Map<String, Course> courseMap = {};
    for (var dayGroup in dayGroups) {
      for (var item in dayGroup.items) {
        if (item.isSelected) {
          String key = '${item.course.name}_${item.course.teacher}';
          if (!courseMap.containsKey(key)) {
            courseMap[key] = Course(name: item.course.name, teacher: item.course.teacher, entries: []);
          }
          courseMap[key]!.entries.add(item.entry);
        }
      }
    }
    coursesToExport = courseMap.values.toList();
    
    if (coursesToExport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one schedule to export.')),
      );
      return;
    }

    final String data = jsonEncode(coursesToExport.map((c) => c.toJson()).toList());
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/my_schedule.mysched');
    await file.writeAsString(data);
    await Share.shareXFiles([XFile(file.path)], text: 'My Schedules Backup');
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Schedules'),
      content: SizedBox(
        width: double.maxFinite,
        child: dayGroups.isEmpty 
          ? const Text('No schedules available to export.')
          : ListView.builder(
          shrinkWrap: true,
          itemCount: dayGroups.length,
          itemBuilder: (context, index) {
            final group = dayGroups[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  title: Text(group.day, style: const TextStyle(fontWeight: FontWeight.bold)),
                  value: group.isSelected,
                  onChanged: (val) {
                    setState(() {
                      group.isSelected = val ?? false;
                      for (var item in group.items) {
                        item.isSelected = group.isSelected;
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: Column(
                    children: group.items.map((item) {
                      return CheckboxListTile(
                        title: Text('${item.course.name} by ${item.course.teacher}'),
                        subtitle: Text('${_formatTime(context, item.entry.startTime)} to ${_formatTime(context, item.entry.endTime)}'),
                        value: item.isSelected,
                        onChanged: (val) {
                          setState(() {
                            item.isSelected = val ?? false;
                            group.isSelected = group.items.every((i) => i.isSelected);
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _export,
          child: const Text('Share'),
        ),
      ],
    );
  }
}
