import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_item.dart';

class TaskService {
  final _supabase = Supabase.instance.client;
  String get _userId => _supabase.auth.currentUser!.id;

  // ==========================================================
  // 1. AMBIL SEMUA TUGAS
  // ==========================================================
  Future<List<TaskItem>> getTasks() async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('*, courses(course_name)')
          .eq('user_id', _userId)
          .order('deadline', ascending: true);

      // Karena ID di DB adalah String (UUID), parsing aman
      return (response as List).map((e) => TaskItem.fromMap(e)).toList();
    } catch (e) {
      print('Error get tasks: $e');
      return [];
    }
  }

  // ==========================================================
  // 2. TAMBAH TUGAS BARU
  // ==========================================================
  Future<void> addTask({
    required String courseId,
    required String title,
    required String details,
    required DateTime deadline,
  }) async {
    final String? validCourseId = (courseId.isEmpty) ? null : courseId;

    await _supabase.from('tasks').insert({
      'user_id': _userId,
      'course_id': validCourseId,
      'title': title,
      'details': details,
      // ✅ BENAR: Konversi ke UTC agar jam tidak berubah saat disimpan
      'deadline': deadline.toUtc().toIso8601String(),
      'status': 'pending',
    });
  }

  // ==========================================================
  // 3. UPDATE / EDIT TUGAS (PENTING BUAT FITUR EDIT)
  // ==========================================================
  Future<void> updateTask({
    required String taskId,
    required String title,
    required String details,
    required String courseId,
    required DateTime deadline,
  }) async {
    final String? validCourseId = (courseId.isEmpty) ? null : courseId;

    await _supabase
        .from('tasks')
        .update({
          'title': title,
          'details': details,
          'course_id': validCourseId,
          // ✅ BENAR: Jangan lupa .toUtc() disini juga!
          'deadline': deadline.toUtc().toIso8601String(),
        })
        .eq('id', taskId);
  }

  // ==========================================================
  // 4. UPDATE STATUS (Checklist Selesai)
  // ==========================================================
  Future<void> toggleComplete(String taskId, bool isChecked) async {
    final newStatus = isChecked ? 'completed' : 'pending';

    await _supabase
        .from('tasks')
        .update({'status': newStatus})
        .eq('id', taskId);
  }

  // ==========================================================
  // 5. HAPUS TUGAS
  // ==========================================================
  Future<void> deleteTask(String taskId) async {
    await _supabase.from('tasks').delete().eq('id', taskId);
  }

  // ==========================================================
  // 6. DROPDOWN MATA KULIAH
  // ==========================================================
  Future<List<Map<String, dynamic>>> getCoursesForDropdown() async {
    try {
      final response = await _supabase
          .from('courses')
          .select('id, course_name')
          .eq('user_id', _userId)
          .order('course_name', ascending: true);

      return (response as List)
          .map((item) => {'id': item['id'], 'name': item['course_name']})
          .toList();
    } catch (e) {
      return [];
    }
  }
}
