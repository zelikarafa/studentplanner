import 'package:flutter/material.dart';
// 1. TAMBAHKAN IMPORT DARI PAKET 'intl'
import 'package:intl/date_symbol_data_local.dart';
import 'models/study_item.dart';
import 'models/task_item.dart';
import 'screens/auth/signin_screen.dart'; 
import 'screens/home_screen.dart'; 
// Pastikan semua file di atas sudah di-import dengan path yang benar

// 2. JADIKAN main() ASYNC
void main() async {
  // Wajib dipanggil jika menggunakan fungsi async sebelum runApp()
  WidgetsFlutterBinding.ensureInitialized();
  
  // 3. INISIALISASI DATA LOKALE ('id_ID' untuk Indonesia)
  // Perbaikan ini menghilangkan LocaleDataException
  await initializeDateFormatting('id_ID', null); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Study Planner',
      theme: ThemeData(
        primarySwatch: Colors.teal, 
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', 
      ),
      home: const SigninScreen(), 
    );
  }
}

// =======================================================
// Data Aplikasi (AppData) - (Tetap Sama)
// =======================================================

class AppData {
  // List untuk menyimpan Jadwal Kuliah
  static List<StudyItem> collegeSchedules = [
    StudyItem(
      name: 'PEMROGRAMAN MOBILE',
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 0),
      color: Colors.orange,
      lecturerName: 'Dr. John Doe',
      room: 'L-201',
    ),
    StudyItem(
      name: 'STRUKTUR DATA',
      startTime: const TimeOfDay(hour: 11, minute: 0),
      endTime: const TimeOfDay(hour: 12, minute: 0),
      color: Colors.purple,
      lecturerName: 'Prof. Smith',
      room: 'R-305',
    ),
  ];

  // List untuk menyimpan Jadwal Ujian
  static List<StudyItem> examSchedules = [
    StudyItem(
      name: 'UTS IPSI',
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 0),
      color: const Color(0xFF4DB6AC),
      examDate: DateTime(2025, 4, 5), 
      details: 'Mata Kuliah: IPSI', 
      lecturerName: 'Ujian',
      room: 'Aula',
    ),
  ];

  // List untuk menyimpan Tugas
  static List<TaskItem> tasks = [
    TaskItem(
      name: 'IPSI - Tugas 1',
      dueDate: DateTime(2025, 12, 17), 
      dueTime: const TimeOfDay(hour: 23, minute: 59),
      course: 'IPSI',
      details: 'Create a unique emotional story that describes better than words',
      color: Colors.lightGreen,
      status: TaskStatus.to_do,
    ),
    TaskItem(
      name: 'Pemrograman Mobile - Tugas 1',
      dueDate: DateTime(2025, 12, 17),
      dueTime: const TimeOfDay(hour: 10, minute: 30),
      course: 'Pemrograman Mobile',
      details: 'Create a unique emotional story that describes better than words',
      color: Colors.lightGreen,
      status: TaskStatus.completed,
    ),
    TaskItem(
      name: 'UI/UX - Tugas 2 (TELAT)',
      dueDate: DateTime(2025, 12, 16), 
      dueTime: const TimeOfDay(hour: 23, minute: 59),
      course: 'UI/UX',
      details: 'Create a unique emotional story that describes better than words',
      color: Colors.redAccent,
      status: TaskStatus.missed,
    ),
  ];

  // Metode untuk menambahkan data baru
  static void addCollegeSchedule(StudyItem item) {
    collegeSchedules.add(item);
  }

  static void addExamSchedule(StudyItem item) {
    examSchedules.add(item);
  }

  static void addTask(TaskItem item) {
    tasks.add(item);
  }
}