import 'package:flutter/material.dart';

class StudyItem {
  final int id; // ID dari class_schedules (BigInt)
  final String courseId; // Relasi ke courses (UUID)
  final String name; // Nama Mata Kuliah (dari tabel courses)
  final String lecturerName; // (dari tabel courses)
  final String room; // Prioritas: room jadwal > room matkul
  final int dayOfWeek; // 1 = Senin, dst
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String details;
  final Color color; // (dari tabel courses)

  StudyItem({
    required this.id,
    required this.courseId,
    required this.name,
    required this.lecturerName,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.details,
    required this.color,
  });

  // =======================================================
  // DARI SUPABASE (JSON) → APP (DART OBJECT)
  // =======================================================
  factory StudyItem.fromMap(Map<String, dynamic> map) {
    // 1. Ambil data relasi 'courses'
    // Karena kita pakai select('*, courses(*)') di service
    final courseData = map['courses'] ?? {};

    // 2. Helper parsing Waktu (HH:mm:ss) ke TimeOfDay
    TimeOfDay parseTime(String timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    // 3. Helper parsing Warna Hex (#FF0000) ke Color Obj
    Color parseColor(String? hexString) {
      if (hexString == null || hexString.isEmpty) return Colors.blue;
      try {
        return Color(int.parse(hexString.replaceFirst('#', '0xFF')));
      } catch (e) {
        return Colors.blue;
      }
    }

    // 4. Logika Ruangan: Pakai ruangan jadwal, kalau kosong pakai ruangan default matkul
    String displayRoom = map['room'] ?? courseData['room'] ?? 'TBD';

    return StudyItem(
      id: map['id'], // BigInt otomatis jadi int di Dart
      courseId: map['course_id'],
      name: courseData['name'] ?? 'Matkul Dihapus',
      lecturerName: courseData['lecturer'] ?? '-',
      room: displayRoom,
      dayOfWeek: map['day_of_week'] ?? 1,
      startTime: parseTime(map['start_time']),
      endTime: parseTime(map['end_time']),
      details: map['details'] ?? '',
      color: parseColor(courseData['color_code']),
    );
  }
}
