import 'package:flutter/material.dart';

class TaskItem {
  final int id; // BigInt dari DB jadi int
  final String courseId;
  final String courseName; // Hasil JOIN
  final String
  title; // Di DB kolomnya 'title', di kodemu 'name' -> kita pakai title biar konsisten DB
  final String details;
  final DateTime deadline;
  final bool isCompleted;

  TaskItem({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.title,
    required this.details,
    required this.deadline,
    required this.isCompleted,
  });

  // =======================================================
  // LOGIC WARNA & STATUS (Frontend Only)
  // =======================================================

  // Cek apakah tugas terlewat (Deadline sudah lewat & belum selesai)
  bool get isMissed {
    return !isCompleted && DateTime.now().isAfter(deadline);
  }

  // Cek apakah tugas masih To Do (Belum selesai & deadline masih ada)
  bool get isToDo {
    return !isCompleted && !isMissed;
  }

  // Warna Prioritas: Merah (<=3 hari), Biru (<=7 hari), Hijau (>7 hari)
  Color get priorityColor {
    if (isCompleted) return Colors.grey;
    if (isMissed) return Colors.grey; // Atau merah gelap

    final daysLeft = deadline.difference(DateTime.now()).inDays;
    if (daysLeft < 3) return Colors.red;
    if (daysLeft < 7) return Colors.blue;
    return Colors.green;
  }

  // =======================================================
  // FROM SUPABASE
  // =======================================================
  factory TaskItem.fromMap(Map<String, dynamic> map) {
    // Menangani data JOIN dari tabel courses
    final courseData = map['courses'] ?? {};

    return TaskItem(
      id: map['id'],
      courseId: map['course_id'],
      courseName: courseData['course_name'] ?? 'Umum', // Ambil nama matkul
      title:
          map['title'] ??
          map['name'] ??
          'Tanpa Judul', // Handle kolom title/name
      details: map['details'] ?? '',
      deadline: DateTime.parse(map['deadline']).toLocal(),
      isCompleted: map['is_completed'] ?? false,
    );
  }
}
