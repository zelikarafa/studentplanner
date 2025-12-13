import 'package:flutter/material.dart';

class TaskItem {
  final String id; // <--- UBAH JADI STRING (Supaya cocok sama UUID Database)
  final String courseId;
  final String courseName;
  final String title;
  final String details;
  final DateTime deadline;
  final String status;

  TaskItem({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.title,
    required this.details,
    required this.deadline,
    required this.status,
  });

  // =======================================================
  // LOGIC STATUS & WARNA
  // =======================================================
  bool get isDone => status == 'completed';

  bool get isMissed {
    return status == 'pending' && DateTime.now().isAfter(deadline);
  }

  bool get isToDo {
    return status == 'pending' && !isMissed;
  }

  Color get priorityColor {
    if (isDone) return Colors.green;
    if (isMissed) return Colors.grey;

    final daysLeft = deadline.difference(DateTime.now()).inDays;
    if (daysLeft < 3) return Colors.red;
    if (daysLeft < 7) return Colors.blue;
    return const Color(0xFF2ACDAB);
  }

  // =======================================================
  // FROM SUPABASE
  // =======================================================
  factory TaskItem.fromMap(Map<String, dynamic> map) {
    final courseData = map['courses'] ?? {};

    return TaskItem(
      // Pakai .toString() biar aman, apapun tipe dari DB dianggap String
      id: map['id'].toString(),
      courseId: map['course_id'] ?? '',
      courseName: courseData['course_name'] ?? 'Umum',
      title: map['title'] ?? 'Tanpa Judul',
      details: map['details'] ?? '',
      deadline: DateTime.parse(map['deadline']).toLocal(),
      status: map['status'] ?? 'pending',
    );
  }
}
