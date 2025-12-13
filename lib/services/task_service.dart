import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_item.dart';

class TaskService {
  final _supabase = Supabase.instance.client;
  String get _userId => _supabase.auth.currentUser!.id;

  // 1. AMBIL SEMUA TUGAS (JOIN dengan Courses)
  Future<List<TaskItem>> getTasks() async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('*, courses(course_name)') // Pastikan relasi courses benar
          .eq('user_id', _userId)
          .order('deadline', ascending: true);

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
    await _supabase.from('tasks').insert({
      'user_id': _userId,
      'course_id': courseId,
      'title': title, // Sesuai kolom DB
      'details': details,
      'deadline': deadline.toIso8601String(),
      'is_completed': false,
    });
  }

  // 3. UPDATE STATUS (Checklist Selesai/Belum)
  Future<void> toggleComplete(int taskId, bool currentValue) async {
    await _supabase
        .from('tasks')
        .update({
          'is_completed': !currentValue,
        }) // Balik nilainya (True jadi False, dst)
        .eq('id', taskId);
  }

  // 4. HAPUS TUGAS
  Future<void> deleteTask(int taskId) async {
    await _supabase.from('tasks').delete().eq('id', taskId);
  }

  // 5. AMBIL COURSE UTK DROPDOWN
  Future<List<Map<String, dynamic>>> getCoursesForDropdown() async {
    final response = await _supabase
        .from('courses')
        .select(
          'id, course_name',
        ) // Pastikan nama kolom 'course_name' sesuai tabel courses kamu
        .eq('user_id', _userId)
        .order('course_name', ascending: true);

    // Mapping hasilnya agar UI mudah membacanya
    return (response as List)
        .map((item) => {'id': item['id'], 'name': item['course_name']})
        .toList();
  }
}
