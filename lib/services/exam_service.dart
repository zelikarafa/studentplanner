import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/exam_item.dart';

class ExamService {
  final _supabase = Supabase.instance.client;
  String get _userId => _supabase.auth.currentUser!.id;

  // 1. AMBIL DATA UJIAN
  Future<List<ExamItem>> getExams() async {
    try {
      final response = await _supabase
          .from('exam_schedules')
          .select('*, courses(course_name)') // JOIN ke courses
          .eq('user_id', _userId)
          .order('exam_date', ascending: true); // Urutkan tanggal terdekat

      return (response as List).map((e) => ExamItem.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error get exams: $e');
      return [];
    }
  }

  // 2. TAMBAH UJIAN
  Future<void> addExam({
    required String courseId,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String details,
    required String notes,
  }) async {
    // Helper TimeOfDay ke String "HH:mm:00"
    String formatTime(TimeOfDay t) => '${t.hour}:${t.minute}:00';

    await _supabase.from('exam_schedules').insert({
      'user_id': _userId,
      'course_id': courseId,
      'exam_date': date.toIso8601String(),
      'start_time': formatTime(startTime),
      'end_time': formatTime(endTime),
      'details': details,
      'notes': notes,
    });
  }

  // 3. HAPUS UJIAN
  Future<void> deleteExam(int id) async {
    await _supabase.from('exam_schedules').delete().eq('id', id);
  }

  // 4. AMBIL LIST MATKUL (Dropdown)
  Future<List<Map<String, dynamic>>> getCoursesForDropdown() async {
    final response = await _supabase
        .from('courses')
        .select('id, course_name')
        .eq('user_id', _userId)
        .order('course_name', ascending: true);

    return (response as List)
        .map((item) => {'id': item['id'], 'name': item['course_name']})
        .toList();
  }
}
