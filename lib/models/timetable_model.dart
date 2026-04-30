import 'package:flutter/material.dart';

class TimetableEntry {
  final String id;
  final String day;
  final String room;
  final int startTime; // Minutes from start of day
  final int endTime;   // Minutes from start of day
  final Color color;

  TimetableEntry({
    required this.id,
    required this.day,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.color,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      day: json['day'],
      room: json['room'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      color: _parseColor(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'room': room,
      'startTime': startTime,
      'endTime': endTime,
      'color': '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
    };
  }

  static Color _parseColor(String colorHex) {
    try {
      if (colorHex.startsWith('#')) {
        return Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
      }
      return Color(int.parse(colorHex));
    } catch (e) {
      return Colors.blue;
    }
  }

  TimetableEntry copyWith({
    String? day,
    String? room,
    int? startTime,
    int? endTime,
    Color? color,
  }) {
    return TimetableEntry(
      id: id,
      day: day ?? this.day,
      room: room ?? this.room,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
    );
  }
}

class Course {
  final String name;
  final String teacher;
  final List<TimetableEntry> entries;

  Course({
    required this.name,
    required this.teacher,
    required this.entries,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      name: json['course'],
      teacher: json['teacher'],
      entries: (json['entries'] as List)
          .map((e) => TimetableEntry.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course': name,
      'teacher': teacher,
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }
}
