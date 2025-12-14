import 'package:flutter/material.dart';

class ExamItem {
  final int id;
  final String courseId;
  final String courseName;
  final DateTime examDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String room; // ✅ Tambah Ruangan
  final String details;
  final String notes;

  ExamItem({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.details,
    required this.notes,
  });

  factory ExamItem.fromMap(Map<String, dynamic> map) {
    TimeOfDay parseTime(String timeStr) {
      try {
        final parts = timeStr.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (e) {
        return const TimeOfDay(hour: 0, minute: 0);
      }
    }

    final courseData = map['courses'] ?? {};

    return ExamItem(
      id: map['id'],
      courseId: map['course_id'] ?? '',
      courseName: courseData['course_name'] ?? 'Ujian Umum',
      examDate: DateTime.parse(map['exam_date']),
      startTime: parseTime(map['start_time']),
      endTime: parseTime(map['end_time']),
      room: map['room'] ?? '-', // ✅ Mapping Ruangan
      details: map['details'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}
