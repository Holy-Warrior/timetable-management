import 'package:timetable/shared_memory.dart';

class TimeTable {
  late List<Map<String, dynamic>> table;
  String status = 'loading';
  late Function callback;

  TimeTable(this.callback) {
    _loadData().then((_) => callback());
  }

  Future<void> _loadData() async {
    /*
      I fucking hate dart's typecasting! 
      It makes me focus on things i shouldn't
      be focusing on. I just want to get the 
      data and use it, not worry about.
    */
    dynamic data = await sharedMemory('savedTimeTable', null, true);
    if (data != null) {
      table =
          (data as List).map((e) {
            final map = Map<String, dynamic>.from(e);
            map['entries'] =
                (map['entries'] as List)
                    .map((entry) => Map<String, dynamic>.from(entry))
                    .toList();
            return map;
          }).toList();
      status = 'ready';
    } else {
      table = [];
      status = 'empty';
    }
  }

  Future<void> _saveData() async {
    status = 'ready';
    await sharedMemory('savedTimeTable', table, true);
  }

  void addEntry(
    String course,
    String teacher,
    String day,
    String room,
    int startTime,
    int endTime,
    String color,
  ) async {
    final id = getTableId(course, teacher);

    final entries = {
      "day": day,
      "room": room,
      "startTime": startTime,
      "endTime": endTime,
      "color": color,
    };

    if (id >= 0) {
      if (hasEntryValue(id, entries)) return;
      table[id]['entries'].add(entries);
    } else {
      table.add({
        "course": course,
        "teacher": teacher,
        "entries": [entries],
      });
    }
    _saveData();
    callback();
  }

  int getTableId(String course, String teacher) {
    return table.indexWhere(
      (entry) => entry['course'] == course && entry['teacher'] == teacher,
    );
  }

  bool hasEntryValue(id, entries) {
    return table[id]['entries'].every((value) => value == entries);
  }

  void deleteEntry(id, entryid) {
    if (id < 0 || id >= table.length) return;
    if (table[id]['entries'].singleOrNull != null) {
      table.removeAt(id);
    } else {
      table[id]['entries'].removeAt(entryid);
    }
    _saveData();
  }

  void deleteEntryByCourseAndTeacher(String course, String teacher, entryId) {
    final id = getTableId(course, teacher);
    if (id >= 0) {
      if (table[id]['entries'].singleOrNull != null) {
        table.removeAt(id);
      } else if (entryId < table[id]['entries'].length) {
        table[id]['entries'].removeAt(entryId);
        _saveData();
      }
    }
  }

  // ignore: unused_element
  List<Map<String, dynamic>>? getEntriesByDayWithCourseAndTeacher(day) {
    /*
    returning data structure:
    [{
      'table id': 0,
      'entry id': 0,
      'course': 'Course Name',
      'teacher': 'Teacher Name',
      'day': 'Monday',
      'room': 'Room 101',
      'startTime': 9,
      'endTime': 10,
      'color': '#FF0000'
    },
    ...]
    */
    List<Map<String, dynamic>> results = [];

    if (table.isEmpty) return null;
    for (var course in table) {
      if (course['entries'].isEmpty) return null;
      for (var entry in course['entries']) {
        if (entry['day'] == day) {
          results.add({
            // formatting the data as one map
            'table id': table.indexOf(course),
            'entry id': course['entries'].indexOf(entry),
            'course': course['course'],
            'teacher': course['teacher'],
            'day': entry['day'],
            'room': entry['room'],
            'startTime': entry['startTime'],
            'endTime': entry['endTime'],
            'color': entry['color'],
          });
        }
      }
    }
    return results.isNotEmpty ? results : null;
  }

  List<String>? getAvailableDays() {
    List<String> availableDays = [];
    for (var entries in table) {
      for (var entry in entries['entries']) {
        if (!availableDays.contains(entry['day'])) {
          availableDays.add(entry['day']);
        }
      }
    }
    return availableDays.isNotEmpty ? availableDays : null;
  }

  Map<String, List<String>> getUniqueValues() {
    final Map<String, List<String>> myMap = {
      'course': [],
      'teacher': [],
      'day': [],
      'room': [],
      // 'startTime': [],
      // 'endTime': [],
      // 'color': [],
    };

    for (var course in table) {
      if (!myMap['course']!.contains(course['course'])) {
        myMap['course']!.add(course['course']);
      }
      if (!myMap['teacher']!.contains(course['teacher'])) {
        myMap['teacher']!.add(course['teacher']);
      }
      for (var entry in course['entries']) {
        if (!myMap['day']!.contains(entry['day'])) {
          myMap['day']!.add(entry['day']);
        }
        if (!myMap['room']!.contains(entry['room'])) {
          myMap['room']!.add(entry['room']);
        }
        // if (!myMap['startTime']!.contains(entry['startTime'])) {
        //   myMap['startTime']!.add(entry['startTime']);
        // }
        // if (!myMap['endTime']!.contains(entry['endTime'])) {
        //   myMap['endTime']!.add(entry['endTime']);
        // }
        // if (!myMap['color']!.contains(entry['color'])) {
        //   myMap['color']!.add(entry['color']);
        // }
      }
    }
    return myMap;
  }
}

// the table structure is like this:
// table = [
//         {
//             "course":"course name",
//             "teacher":"teacher name",
//             "entries":[
//                 {
//                     "day":"monday",
//                     "room":"308",
//                     "startTime":1719522780000,
//                     "endTime":2719522780000,
//                     "color":"#d4d4d4"
//                 },
//                 {
//                     "day":"monday",
//                     "room":"Lab 303",
//                     "startTime":2719522780000,
//                     "endTime":3719522780000,
//                     "color":"#d4d4d4"
//                 }
//             ]
//         },
//         {
//             "course":"course name",
//             "teacher":"teacher name",
//             "entries":[
//                 {
//                     "day":"monday",
//                     "room":"308",
//                     "startTime":1719522780000,
//                     "endTime":2719522780000,
//                     "color":"#d4d4d4"
//                 },
//                 {
//                     "day":"monday",
//                     "room":"Lab 303",
//                     "startTime":2719522780000,
//                     "endTime":3719522780000,
//                     "color":"#d4d4d4"
//                 }
//             ]
//         }
//     ]
