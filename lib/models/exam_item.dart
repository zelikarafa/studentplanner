import 'package:flutter/material.dart';

class ExamItem {
  final int id;
  final String courseId;
  final String courseName; // Dari JOIN tabel courses
  final DateTime examDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String details;
  final String notes; // Fitur khusus Ujian

  ExamItem({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    required this.details,
    required this.notes,
  });

  factory ExamItem.fromMap(Map<String, dynamic> map) {
    // Helper parsing Waktu "HH:mm:ss" -> TimeOfDay
    TimeOfDay parseTime(String timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    final courseData = map['courses'] ?? {};

    return ExamItem(
      id: map['id'],
      courseId: map['course_id'],
      courseName: courseData['course_name'] ?? 'Ujian Umum',
      examDate: DateTime.parse(map['exam_date']),
      startTime: parseTime(map['start_time']),
      endTime: parseTime(map['end_time']),
      details: map['details'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}
