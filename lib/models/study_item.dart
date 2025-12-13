import 'package:flutter/material.dart';

class StudyItem {
  final int id;
  final String courseId;
  final String name; // Nama Matkul (Diambil dari tabel courses)
  final String lecturer; // Dosen (Diambil dari tabel courses)
  final String room; // Prioritas: Room Jadwal > Room Default Matkul
  final int dayOfWeek;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? details;
  final Color color; // Default color jika tidak ada di DB

  StudyItem({
    required this.id,
    required this.courseId,
    required this.name,
    required this.lecturer,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.details,
    this.color = const Color(0xFF2ACDAB), // Warna default hijau tosca
  });

  factory StudyItem.fromMap(Map<String, dynamic> map) {
    // 1. Ambil Data Induk (Mata Kuliah)
    // Supabase mengembalikan object 'courses' karena kita pakai join
    final courseData = map['courses'] ?? {};

    // 2. Logika Ruangan (Pakai ruangan jadwal, kalau null pakai ruangan default matkul)
    String finalRoom = map['room'] ?? courseData['room'] ?? 'Belum ditentukan';

    // 3. Parsing Waktu (HH:mm:ss -> TimeOfDay)
    TimeOfDay parseTime(String timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return StudyItem(
      id: map['id'],
      courseId: map['course_id'],
      // Hati-hati: Di tabel courses kolomnya 'course_name' sesuai gambar DB kamu
      name: courseData['course_name'] ?? 'Tanpa Nama',
      lecturer: courseData['lecturer'] ?? '-',
      room: finalRoom,
      dayOfWeek: map['day_of_week'],
      startTime: parseTime(map['start_time']),
      endTime: parseTime(map['end_time']),
      details: map['details'],
    );
  }
}
