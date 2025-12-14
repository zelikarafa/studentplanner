import 'package:flutter/material.dart';

class StudyItem {
  final int id;
  final String courseId;
  final String name; // Nama Matkul
  // ✅ PERBAIKAN 1: Jadikan String? karena bisa null
  final String? lecturer;
  // ✅ PERBAIKAN 2: Jadikan String? karena bisa null (meskipun di UI kita buat default)
  final String? room;
  final int dayOfWeek;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? details;
  final Color color;

  StudyItem({
    required this.id,
    required this.courseId,
    required this.name,
    this.lecturer, // TIDAK LAGI REQUIRED
    this.room, // TIDAK LAGI REQUIRED
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.details,
    this.color = const Color(0xFF2ACDAB),
  });

  factory StudyItem.fromMap(Map<String, dynamic> map) {
    final courseData = map['courses'] ?? {};

    // Logika Ruangan: Pakai ruangan jadwal (String) > Room Default Matkul (String) > null
    String? finalRoom;
    if (map['room'] != null && (map['room'] as String).isNotEmpty) {
      finalRoom = map['room'];
    } else if (courseData['room'] != null &&
        (courseData['room'] as String).isNotEmpty) {
      finalRoom = courseData['room'];
    }

    // Parsing Waktu (HH:mm:ss -> TimeOfDay)
    TimeOfDay parseTime(String timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return StudyItem(
      id: map['id'],
      courseId: map['course_id'],
      name: courseData['course_name'] ?? 'Tanpa Nama',
      lecturer: courseData['lecturer'] as String?,
      room: finalRoom,
      dayOfWeek: map['day_of_week'],
      startTime: parseTime(map['start_time']),
      endTime: parseTime(map['end_time']),
      details: map['details'] as String?,
    );
  }
}
