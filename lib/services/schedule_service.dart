import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/study_item.dart';

class ScheduleService {
  final _supabase = Supabase.instance.client;

  String get _userId => _supabase.auth.currentUser!.id;

  // ==========================================
  // 1. READ SCHEDULES (Jadwal + Data Matkul)
  // ==========================================
  Future<List<StudyItem>> getSchedules() async {
    try {
      final response = await _supabase
          .from('class_schedules')
          // Syntax Magic: Ambil semua kolom jadwal, DAN kolom detail dari tabel courses
          .select('*, courses(name, lecturer, room, color_code)')
          .eq('user_id', _userId)
          .order('day_of_week', ascending: true)
          .order('start_time', ascending: true);

      // Konversi data JSON ke List<StudyItem>
      return (response as List).map((e) => StudyItem.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error fetch schedules: $e');
      return [];
    }
  }

  // ==========================================
  // 2. READ COURSES (Untuk Dropdown Matkul)
  // ==========================================
  Future<List<Map<String, dynamic>>> getCoursesForDropdown() async {
    final response = await _supabase
        .from('courses')
        // PERBAIKAN: Ambil 'course_name' sebagai 'name' agar UI tidak error
        .select('id, course_name')
        .eq('user_id', _userId)
        .order('course_name', ascending: true);

    // Mapping agar di UI tetap terbaca sebagai 'name'
    return (response as List).map((item) {
      return {
        'id': item['id'],
        'name':
            item['course_name'], // Mapping dari database course_name ke key 'name'
      };
    }).toList();
  }

  // ==========================================
  // 3. INSERT (TAMBAH JADWAL)
  // ==========================================
  // Kita tidak kirim nama/warna, tapi kirim course_id
  Future<void> addSchedule({
    required String courseId, // UUID dari Dropdown
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    String? room, // Opsional, override default room
    String? details,
  }) async {
    await _supabase.from('class_schedules').insert({
      'user_id': _userId,
      'course_id': courseId,
      'day_of_week': dayOfWeek,
      'start_time': _timeToString(startTime),
      'end_time': _timeToString(endTime),
      'room': room,
      'details': details,
    });
  }

  // ==========================================
  // 4. DELETE
  // ==========================================
  Future<void> deleteSchedule(int scheduleId) async {
    await _supabase
        .from('class_schedules')
        .delete()
        .eq('id', scheduleId)
        .eq('user_id', _userId);
  }

  // ==========================================
  // HELPER
  // ==========================================
  String _timeToString(TimeOfDay time) {
    // Format ke HH:mm:00 agar diterima PostgreSQL Time type
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }
}
