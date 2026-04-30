import 'package:flutter/material.dart';
import 'package:timetable/models/timetable_model.dart';
import 'package:timetable/timetable_controller.dart';
import 'package:timetable/timetable_form.dart';
import 'package:timetable/widget_git_release_checker.dart';
import 'package:timetable/common_data.dart';
import 'package:timetable/settings_screen.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  String _formatTime(BuildContext context, int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final time = TimeOfDay(hour: hour, minute: minute);
    return time.format(context);
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> data) {
    final String course = data['course'];
    final String teacher = data['teacher'];
    final TimetableEntry entry = data['entry'];
    final tt = context.read<TimeTable>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => TimetableForm(
                    timeTable: tt,
                    entryToEdit: entry,
                    courseName: course,
                    teacherName: teacher,
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: entry.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Teacher: $teacher',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Room: ${entry.room}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(context, entry.startTime),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatTime(context, entry.endTime),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  _buildETA(entry),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildETA(TimetableEntry entry) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(
        const Duration(seconds: 30),
        (_) => DateTime.now(),
      ),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data!;

        final List<String> weekDays = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ];
        final int currentDayIndex = now.weekday - 1;
        final int currentMin =
            currentDayIndex * 24 * 60 + now.hour * 60 + now.minute;

        final int classDayIndex = weekDays.indexOf(entry.day);
        if (classDayIndex == -1) return const SizedBox.shrink();

        final int startMin = classDayIndex * 24 * 60 + entry.startTime;
        int endMin = classDayIndex * 24 * 60 + entry.endTime;
        if (endMin < startMin) endMin += 24 * 60; // Crosses midnight

        const int week = 7 * 24 * 60;

        // Calculate minutes until start, handling weekly wrap-around
        int untilStart = startMin - currentMin;
        if (untilStart < 0) untilStart += week;

        // Check if currently in session
        final int duration = endMin - startMin;
        int timeSinceStart = (currentMin - startMin) % week;
        if (timeSinceStart < 0) timeSinceStart += week;

        bool isNow = timeSinceStart < duration;
        int untilEnd = isNow ? (duration - timeSinceStart) : 0;

        if (untilStart > 0 && untilStart <= 60) {
          return Text(
            'Starts in $untilStart min',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          );
        } else if (isNow) {
          if (untilEnd <= 60) {
            return Text(
              'Ends in $untilEnd min',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            );
          } else {
            return const Text(
              'NOW',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TimetableForm(timeTable: context.read<TimeTable>()),
          ),
        );
      },
      label: const Text('Add Schedule'),
      icon: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeTable>(
      builder: (context, tt, _) {
        if (tt.status == 'loading') {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final availableDays = tt.getAvailableDays();

        if (availableDays.isEmpty) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              title: const Text('My Schedule'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                ),
              ],
            ),
            body: Column(
              children: [
                WidgetGitReleaseChecker(
                  user: githubUserName,
                  repo: githubRepoName,
                  currentRelease: currentRelease,
                  filterOutPreRelease: false,
                  showLoading: false,
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No classes scheduled',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: _buildFAB(context),
          );
        }

        // Try to set the initial tab to today if it exists, otherwise use 0
        final todayIndex = DateTime.now().weekday - 1;
        final List<String> allDays = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ];
        final todayName = allDays[todayIndex];
        final initialIndex =
            availableDays.contains(todayName)
                ? availableDays.indexOf(todayName)
                : 0;

        return DefaultTabController(
          length: availableDays.length,
          initialIndex: initialIndex,
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              title: const Text('My Schedule'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: availableDays.map((day) => Tab(text: day)).toList(),
              ),
            ),
            body: Column(
              children: [
                WidgetGitReleaseChecker(
                  user: githubUserName,
                  repo: githubRepoName,
                  currentRelease: currentRelease,
                  filterOutPreRelease: false,
                  showLoading: false,
                ),
                Expanded(
                  child: TabBarView(
                    children:
                        availableDays.map((day) {
                          final entries = tt.getEntriesByDay(day);
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: entries.length,
                            itemBuilder:
                                (context, index) =>
                                    _buildCourseCard(context, entries[index]),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
            floatingActionButton: _buildFAB(context),
          ),
        );
      },
    );
  }
}
