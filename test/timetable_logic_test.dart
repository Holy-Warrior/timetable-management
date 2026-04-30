import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timetable/timetable_controller.dart';
import 'package:timetable/models/timetable_model.dart';
import 'package:flutter/material.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TimeTable Controller Logic Tests', () {
    late TimeTable timeTable;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      timeTable = TimeTable();
    });

    test('Initial state should be empty', () async {
      // Need to wait for loadData
      await Future.delayed(const Duration(milliseconds: 100));
      expect(timeTable.courses.isEmpty, true);
      expect(timeTable.status, 'empty');
      expect(timeTable.notificationsEnabled, true);
      expect(timeTable.notificationOffset, 10);
    });

    test(
      'Adding a new entry creates a course and schedules notification',
      () async {
        await Future.delayed(const Duration(milliseconds: 100));
        final entry = TimetableEntry(
          id: 'test_id',
          day: 'Monday',
          startTime: 600, // 10:00 AM
          endTime: 660, // 11:00 AM
          room: '101',
          color: Colors.blue,
        );

        timeTable.addOrUpdateEntry(
          courseName: 'Math',
          teacher: 'Mr. Smith',
          entry: entry,
        );

        await Future.delayed(const Duration(milliseconds: 100));
        expect(timeTable.courses.length, 1);
        expect(timeTable.courses.first.name, 'Math');
        expect(timeTable.courses.first.entries.length, 1);
        expect(timeTable.courses.first.entries.first.room, '101');
      },
    );

    test('Modifying an entry updates it correctly', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      final entry1 = TimetableEntry(
        id: '1',
        day: 'Monday',
        startTime: 600,
        endTime: 660,
        room: '101',
        color: Colors.blue,
      );
      timeTable.addOrUpdateEntry(
        courseName: 'Math',
        teacher: 'Smith',
        entry: entry1,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      final entry2 = TimetableEntry(
        id: '1',
        day: 'Tuesday',
        startTime: 700,
        endTime: 760,
        room: '102',
        color: Colors.red,
      );
      timeTable.addOrUpdateEntry(
        courseName: 'Math',
        teacher: 'Smith',
        entry: entry2,
        entryIdToUpdate: '1',
      );
      await Future.delayed(const Duration(milliseconds: 100));

      expect(timeTable.courses.first.entries.length, 1);
      expect(timeTable.courses.first.entries.first.day, 'Tuesday');
      expect(timeTable.courses.first.entries.first.room, '102');
    });

    test('Deleting an entry removes it correctly', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      final entry1 = TimetableEntry(
        id: '1',
        day: 'Monday',
        startTime: 600,
        endTime: 660,
        room: '101',
        color: Colors.blue,
      );
      timeTable.addOrUpdateEntry(
        courseName: 'Math',
        teacher: 'Smith',
        entry: entry1,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      expect(timeTable.courses.length, 1);

      timeTable.deleteEntry('Math', 'Smith', '1');
      await Future.delayed(const Duration(milliseconds: 100));

      expect(timeTable.courses.isEmpty, true);
    });

    test('Toggling notifications updates state', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      await timeTable.toggleNotifications(false);
      expect(timeTable.notificationsEnabled, false);

      await timeTable.toggleNotifications(true);
      expect(timeTable.notificationsEnabled, true);
    });

    test('Setting offset updates state', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      await timeTable.setNotificationOffset(30);
      expect(timeTable.notificationOffset, 30);

      await timeTable.setNotificationOffset(60);
      expect(timeTable.notificationOffset, 60);
    });
  });
}
