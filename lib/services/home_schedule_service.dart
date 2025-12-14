// lib/services/home_schedule_service.dart

import '../models/study_item.dart';
import '../models/exam_item.dart';
import 'schedule_service.dart'; // Import service yang sudah ada
import 'exam_service.dart'; // Import service yang sudah ada

class HomeScheduleService {
  final ScheduleService _scheduleService = ScheduleService();
  final ExamService _examService = ExamService();

  /// Mengambil dan menggabungkan StudyItem dan ExamItem untuk hari ini,
  /// lalu mengurutkannya berdasarkan waktu.
  Future<List<dynamic>> getTodaysEvents() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Ambil semua jadwal (kelas mingguan) dan ujian
    final List<StudyItem> allClasses = await _scheduleService.getSchedules();
    final List<ExamItem> allExams = await _examService.getExams();

    List<dynamic> todaysEvents = [];

    // 2. Filter Kelas (Berdasarkan HARI ini dalam seminggu)
    // DateTime.weekday: 1=Senin, 7=Minggu
    final selectedDayOfWeek = today.weekday;
    for (var cls in allClasses) {
      if (cls.dayOfWeek == selectedDayOfWeek) {
        todaysEvents.add(cls);
      }
    }

    // 3. Filter Ujian (Berdasarkan TANGGAL persis hari ini)
    for (var exam in allExams) {
      if (exam.examDate.year == today.year &&
          exam.examDate.month == today.month &&
          exam.examDate.day == today.day) {
        todaysEvents.add(exam);
      }
    }

    // 4. Urutkan berdasarkan Jam Mulai
    todaysEvents.sort((a, b) {
      final timeA = (a is StudyItem) ? a.startTime : (a as ExamItem).startTime;
      final timeB = (b is StudyItem) ? b.startTime : (b as ExamItem).startTime;

      int minutesA = timeA.hour * 60 + timeA.minute;
      int minutesB = timeB.hour * 60 + timeB.minute;
      return minutesA.compareTo(minutesB);
    });

    return todaysEvents;
  }
}
