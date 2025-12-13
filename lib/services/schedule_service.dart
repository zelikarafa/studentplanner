import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/study_item.dart';

class ScheduleService {
  final _supabase = Supabase.instance.client;

  String get _userId => _supabase.auth.currentUser!.id;

  // ==========================================
  // 1. READ SCHEDULES
  // ==========================================
  Future<List<StudyItem>> getSchedules() async {
    try {
      final response = await _supabase
          .from('class_schedules')
          // PERBAIKAN DISINI:
          // Gunakan 'course_name' sesuai tabel courses kamu.
          // Hapus 'color_code' jika di tabel courses tidak ada kolom itu.
          .select('*, courses(course_name, lecturer, room)')
          .eq('user_id', _userId)
          .order('day_of_week', ascending: true)
          .order('start_time', ascending: true);

      // Debugging: Cek data mentah di console
      // print("Data Raw Supabase: $response");

      return (response as List).map((e) => StudyItem.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error fetch schedules: $e');
      return [];
    }
  }

  // ==========================================
  // 2. READ COURSES (Untuk Dropdown)
  // ==========================================
  Future<List<Map<String, dynamic>>> getCoursesForDropdown() async {
    try {
      final response = await _supabase
          .from('courses')
          .select('id, course_name, room') // Ambil room juga untuk hint
          .eq('user_id', _userId)
          .order('course_name', ascending: true);

      return (response as List).map((item) {
        return {
          'id': item['id'],
          'name': item['course_name'], // Mapping untuk UI Dropdown
          'default_room': item['room'], // Simpan room default buat logic UI
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetch courses: $e');
      return [];
    }
  }

  // ==========================================
  // 3. INSERT
  // ==========================================
  Future<void> addSchedule({
    required String courseId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    String? room,
    String? details,
  }) async {
    // Validasi sederhana: Ubah string kosong jadi null
    final finalRoom = (room == null || room.trim().isEmpty) ? null : room;
    final finalDetails = (details == null || details.trim().isEmpty)
        ? null
        : details;

    await _supabase.from('class_schedules').insert({
      'user_id': _userId,
      'course_id': courseId,
      'day_of_week': dayOfWeek,
      'start_time': _timeToString(startTime),
      'end_time': _timeToString(endTime),
      'room': finalRoom,
      'details': finalDetails,
    });
  }

  // ==========================================
  // HELPER
  // ==========================================
  String _timeToString(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }
}
