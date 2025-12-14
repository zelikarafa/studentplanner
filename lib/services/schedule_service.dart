import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/study_item.dart';

class ScheduleService {
  final _supabase = Supabase.instance.client;

  // Pastikan user sudah login sebelum memanggil ini, kalau tidak akan crash
  String get _userId => _supabase.auth.currentUser!.id;

  // ==========================================
  // 1. READ SCHEDULES & 2. READ COURSES (SAMA)
  // ==========================================

  // (getSchedules dan getCoursesForDropdown tetap sama seperti yang Anda berikan)
  Future<List<StudyItem>> getSchedules() async {
    try {
      final response = await _supabase
          .from('class_schedules')
          .select('*, courses(course_name, lecturer, room)')
          .eq('user_id', _userId)
          .order('day_of_week', ascending: true)
          .order('start_time', ascending: true);
      return (response as List).map((e) => StudyItem.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error fetch schedules: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCoursesForDropdown() async {
    try {
      final response = await _supabase
          .from('courses')
          .select('id, course_name, room')
          .eq('user_id', _userId)
          .order('course_name', ascending: true);

      return (response as List).map((item) {
        return {
          'id': item['id'],
          'name': item['course_name'],
          'default_room': item['room'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetch courses: $e');
      return [];
    }
  }

  // ==========================================
  // 3. INSERT (SAMA)
  // ==========================================
  Future<void> addSchedule({
    required String courseId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    String? room,
    String? details,
  }) async {
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
  // 4. ✅ TAMBAHAN: UPDATE SCHEDULE
  // ==========================================
  Future<void> updateSchedule({
    required int scheduleId, // Gunakan int sesuai StudyItem
    required String courseId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    String? room,
    String? details,
  }) async {
    final finalRoom = (room == null || room.trim().isEmpty) ? null : room;
    final finalDetails = (details == null || details.trim().isEmpty)
        ? null
        : details;

    await _supabase
        .from('class_schedules')
        .update({
          'course_id': courseId,
          'day_of_week': dayOfWeek,
          'start_time': _timeToString(startTime),
          'end_time': _timeToString(endTime),
          'room': finalRoom,
          'details': finalDetails,
        })
        .eq('id', scheduleId)
        .eq('user_id', _userId);
  }

  // ==========================================
  // 5. ✅ TAMBAHAN: DELETE SCHEDULE
  // ==========================================
  Future<void> deleteSchedule(int scheduleId) async {
    await _supabase
        .from('class_schedules')
        .delete()
        .eq('id', scheduleId)
        .eq('user_id', _userId);
  }

  // ==========================================
  // HELPER (SAMA)
  // ==========================================
  String _timeToString(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }
}
