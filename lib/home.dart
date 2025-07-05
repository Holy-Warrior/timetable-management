import 'package:flutter/material.dart';
import 'package:timetable/timetable_controller.dart';
import 'package:timetable/timetable_form.dart';

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
    // return ListView.builder(
    // itemCount: entries.length,
    // itemBuilder: (context, index) {
    //   final entry = entries[index];
    return Card(
      child: ListTile(
        title: Text(entry['course']),
        subtitle: Text(
          'Teacher: ${entry['teacher']} | Room: ${entry['room']}\n'
          'Starts at: ${entry['startTime']} Ends at: ${entry['endTime']}',
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
    //   },
    // );
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
