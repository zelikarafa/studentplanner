import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_item.dart';

class TaskService {
  final _supabase = Supabase.instance.client;
  String get _userId => _supabase.auth.currentUser!.id;

  // 1. AMBIL SEMUA TUGAS
  Future<List<TaskItem>> getTasks() async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('*, courses(course_name)')
          .eq('user_id', _userId)
          .order('deadline', ascending: true);

      // Karena ID di DB adalah String (UUID), parsing akan aman sekarang
      // karena model TaskItem sudah kita ubah jadi String
      return (response as List).map((e) => TaskItem.fromMap(e)).toList();
    } catch (e) {
      print('Error get tasks: $e');
      return [];
    }
  }

  // 2. TAMBAH TUGAS BARU
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
      'deadline': deadline.toIso8601String(),
      'status': 'pending',
    });
  }

  // 3. UPDATE STATUS (Terima String taskId)
  Future<void> toggleComplete(String taskId, bool isChecked) async {
    final newStatus = isChecked ? 'completed' : 'pending';

    await _supabase
        .from('tasks')
        .update({'status': newStatus})
        .eq('id', taskId); // ID UUID (String) ketemu String = Aman
  }

  // 4. HAPUS TUGAS (Terima String taskId)
  Future<void> deleteTask(String taskId) async {
    await _supabase.from('tasks').delete().eq('id', taskId);
  }

  // 5. DROPDOWN
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
