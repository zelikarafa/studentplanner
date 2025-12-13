// lib/models/task_item.dart

import 'package:flutter/material.dart';

enum TaskStatus { to_do, missed, completed }

class TaskItem {
  final String name;
  final DateTime dueDate;
  final TimeOfDay? dueTime; // TimeOfDay bisa null
  final String course;
  final String details;
  final Color color;
  TaskStatus status;

  TaskItem({
    required this.name,
    required this.dueDate,
    this.dueTime,
    required this.course,
    required this.details,
    required this.color,
    this.status = TaskStatus.to_do,
  });

  // Getter untuk menggabungkan tanggal dan waktu (penting untuk sorting dan check missed)
  DateTime get fullDueDate {
    // Jika dueTime null, anggap deadline di akhir hari (23:59)
    final time = dueTime ?? const TimeOfDay(hour: 23, minute: 59);
    return DateTime(dueDate.year, dueDate.month, dueDate.day, time.hour, time.minute);
  }
}