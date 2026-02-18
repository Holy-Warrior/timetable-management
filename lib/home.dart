import 'package:flutter/material.dart';
import 'package:timetable/common_data.dart';
import 'package:timetable/timetable_controller.dart';
import 'package:timetable/timetable_form.dart';
import 'package:timetable/widget_git_release_checker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _StateHome();
}

class _StateHome extends State<Home> {
  final List daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  late final TimeTable timeTable;
  String? selectedDay;
  String status = 'loading';
  List<Map<String, dynamic>>? selectedEntries;
  bool refresh = false;

  @override
  void initState() {
    super.initState();
    selectedDay = getToday();
    timeTable = TimeTable(() {
      setState(() {
        status = timeTable.status;
        refresh = !refresh;
      });
    });
  }

  String getToday() {
    final now = DateTime.now();
    // DateTime.weekday returns 1 (Monday) to 7 (Sunday)
    return daysOfWeek[now.weekday - 1];
  }

  Widget weekDayNavigationBar() {
    List<String>? dayList = timeTable.getAvailableDays();

    if (dayList == null) {
      return Text('');
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            dayList
                .map(
                  (day) => ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedDay = day;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedDay == day
                              ? Colors.blue[300]
                              : Colors.grey[200],
                    ),
                    child: Text(
                      day,
                      style: TextStyle(
                        color:
                            selectedDay == day ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget courseEntry(entry) {
    String formatTime(dynamic value) {
      if (value is int) {
        final hour = value ~/ 60;
        final minute = value % 60;
        final time = TimeOfDay(hour: hour, minute: minute);
        return time.format(context);
      } else if (value is String && int.tryParse(value) != null) {
        final intVal = int.parse(value);
        final hour = intVal ~/ 60;
        final minute = intVal % 60;
        final time = TimeOfDay(hour: hour, minute: minute);
        return time.format(context);
      }
      return value.toString();
    }

    Widget etaWidget(entry) {
      int? start =
          entry['startTime'] is int
              ? entry['startTime']
              : int.tryParse(entry['startTime'].toString());
      int? end =
          entry['endTime'] is int
              ? entry['endTime']
              : int.tryParse(entry['endTime'].toString());
      if (start == null || end == null) return SizedBox.shrink();
      return StreamBuilder<DateTime>(
        stream: Stream.periodic(
          const Duration(seconds: 30),
          (_) => DateTime.now(),
        ),
        initialData: DateTime.now(),
        builder: (context, snapshot) {
          final now = snapshot.data!;
          final nowMinutes = now.hour * 60 + now.minute;
          final untilStart = start - nowMinutes;
          final untilEnd = end - nowMinutes;
          if (untilStart > 0 && untilStart <= 60) {
            // 60 min or less to start
            return Text(
              'ETA: $untilStart min',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            );
          } else if (untilStart <= 0 && untilEnd > 0 && untilEnd <= 60) {
            // 60 min or less to end
            return Text(
              'ETA: $untilEnd min',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            );
          } else if (untilStart > -60 && untilStart < 0) {
            // Under 60 min have passed since start
            return Text(
              'ETA: ...',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            );
          } else {
            return SizedBox.shrink();
          }
        },
      );
    }

    return Card(
      child: ListTile(
        title: Text(entry['course']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Teacher: ${entry['teacher']}'),
            Text('Room: ${entry['room']}'),
            Row(
              children: [
                Text(
                  'Time: ${formatTime(entry['startTime'])} - ${formatTime(entry['endTime'])}',
                ),
                const SizedBox(width: 8),
                etaWidget(entry),
              ],
            ),
          ],
        ),
        trailing: Container(
          width: 10,
          height: 50,
          color: Color(
            int.parse(entry['color'].substring(1, 7), radix: 16) + 0xFF000000,
          ),
        ),
      ),
    );
  }

  Widget floatingButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 16),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TimetableForm(timeTable: timeTable),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (timeTable.status == 'loading') {
      return Center(child: CircularProgressIndicator());
    }
    if (timeTable.status != 'empty') {
      selectedEntries = timeTable.getEntriesByDayWithCourseAndTeacher(
        selectedDay,
      );
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WidgetGitReleaseChecker(
              user: 'Holy-Warrior',
              repo: 'timetable-management',
              currentRelease: currentRelease,
              filterOutPreRelease: false,
              showLoading: false,
            ),
            if (timeTable.status == 'empty')
              Center(child: Text('No timetable data yet.'))
            else ...[
              weekDayNavigationBar(),
              if (selectedEntries != null)
                Expanded(
                  child: ListView.builder(
                    itemCount: selectedEntries?.length,
                    itemBuilder: (context, index) {
                      final entry = selectedEntries![index];
                      return courseEntry(entry);
                    },
                  ),
                ),
            ],
          ],
        ),
        floatingButton(),
      ],
    );
  }
}
