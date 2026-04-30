import 'package:flutter/material.dart';
import 'package:timetable/models/timetable_model.dart';
import 'package:timetable/shared_memory.dart';
import 'package:timetable/services/notification_service.dart';

class TimeTable extends ChangeNotifier {
  List<Course> _courses = [];
  String status = 'loading';
  bool _notificationsEnabled = true;
  int _notificationOffset = 10;

  List<Course> get courses => _courses;
  bool get notificationsEnabled => _notificationsEnabled;
  int get notificationOffset => _notificationOffset;

  TimeTable() {
    _loadData();
  }

  Future<void> _loadData() async {
    status = 'loading';
    notifyListeners();

    final dynamic data = await sharedMemory('savedTimeTable', null, true);
    if (data != null && data is List) {
      _courses = data.map((e) => Course.fromJson(Map<String, dynamic>.from(e))).toList();
      status = _courses.isEmpty ? 'empty' : 'ready';
    } else {
      _courses = [];
      status = 'empty';
    }

    final notifs = await sharedMemory('notificationsEnabled');
    _notificationsEnabled = notifs is bool ? notifs : true;

    final offset = await sharedMemory('notificationOffset');
    _notificationOffset = offset is int ? offset : 10;

    notifyListeners();
  }

  Future<void> _saveData() async {
    await sharedMemory('savedTimeTable', _courses.map((c) => c.toJson()).toList(), true);
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await sharedMemory('notificationsEnabled', value);
    _rescheduleAllNotifications();
    notifyListeners();
  }

  Future<void> setNotificationOffset(int offset) async {
    _notificationOffset = offset;
    await sharedMemory('notificationOffset', offset);
    _rescheduleAllNotifications();
    notifyListeners();
  }

  void addOrUpdateEntry({
    required String courseName,
    required String teacher,
    required TimetableEntry entry,
    String? entryIdToUpdate,
  }) async {
    final courseIndex = _courses.indexWhere(
      (c) => c.name.toLowerCase() == courseName.toLowerCase() && 
             c.teacher.toLowerCase() == teacher.toLowerCase()
    );

    if (courseIndex >= 0) {
      final entries = List<TimetableEntry>.from(_courses[courseIndex].entries);
      if (entryIdToUpdate != null) {
        final entryIndex = entries.indexWhere((e) => e.id == entryIdToUpdate);
        if (entryIndex >= 0) {
          entries[entryIndex] = entry;
        } else {
          entries.add(entry);
        }
      } else {
        entries.add(entry);
      }
      
      _courses[courseIndex] = Course(
        name: courseName,
        teacher: teacher,
        entries: entries,
      );
    } else {
      _courses.add(Course(
        name: courseName,
        teacher: teacher,
        entries: [entry],
      ));
    }

    status = 'ready';
    await _saveData();
    _rescheduleAllNotifications();
    notifyListeners();
  }

  void _rescheduleAllNotifications() async {
    final service = NotificationService();
    await service.cancelAllNotifications();
    
    if (!_notificationsEnabled) return;


    final List<String> weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    for (var course in _courses) {
      for (var entry in course.entries) {
        final dayIndex = weekDays.indexOf(entry.day) + 1;
        
        int classWeeklyMin = (dayIndex - 1) * 24 * 60 + entry.startTime;
        int notifyWeeklyMin = classWeeklyMin - _notificationOffset;
        if (notifyWeeklyMin < 0) notifyWeeklyMin += 7 * 24 * 60;
        
        int notifyDayIndex = (notifyWeeklyMin ~/ (24 * 60)) + 1;
        int timeInDay = notifyWeeklyMin % (24 * 60);
        int notifyHour = timeInDay ~/ 60;
        int notifyMinute = timeInDay % 60;

        await service.scheduleNotification(
          id: entry.id.hashCode,
          title: 'Upcoming Class: ${course.name}',
          body: 'Room: ${entry.room} starts in $_notificationOffset minutes',
          hour: notifyHour,
          minute: notifyMinute,
          dayOfWeek: notifyDayIndex,
        );
      }
    }
  }

  void deleteEntry(String courseName, String teacher, String entryId) async {
    final courseIndex = _courses.indexWhere(
      (c) => c.name == courseName && c.teacher == teacher
    );

    if (courseIndex >= 0) {
      final entries = List<TimetableEntry>.from(_courses[courseIndex].entries);
      entries.removeWhere((e) => e.id == entryId);

      if (entries.isEmpty) {
        _courses.removeAt(courseIndex);
      } else {
        _courses[courseIndex] = Course(
          name: courseName,
          teacher: teacher,
          entries: entries,
        );
      }

      if (_courses.isEmpty) status = 'empty';
      await _saveData();
      _rescheduleAllNotifications();
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getEntriesByDay(String day) {
    List<Map<String, dynamic>> results = [];
    for (var course in _courses) {
      for (var entry in course.entries) {
        if (entry.day == day) {
          results.add({
            'course': course.name,
            'teacher': course.teacher,
            'entry': entry,
          });
        }
      }
    }
    // Sort by start time
    results.sort((a, b) => (a['entry'] as TimetableEntry).startTime.compareTo((b['entry'] as TimetableEntry).startTime));
    return results;
  }

  List<String> getAvailableDays() {
    final Set<String> days = {};
    for (var course in _courses) {
      for (var entry in course.entries) {
        days.add(entry.day);
      }
    }
    final List<String> weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekDays.where((d) => days.contains(d)).toList();
  }

  Map<String, List<String>> getUniqueValues() {
    final Set<String> coursesSet = {};
    final Set<String> teachersSet = {};
    final Set<String> roomsSet = {};

    for (var course in _courses) {
      coursesSet.add(course.name);
      teachersSet.add(course.teacher);
      for (var entry in course.entries) {
        roomsSet.add(entry.room);
      }
    }

    return {
      'course': coursesSet.toList(),
      'teacher': teachersSet.toList(),
      'room': roomsSet.toList(),
    };
  }
}
