import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/schedule_service.dart';
import '../../services/exam_service.dart'; // Tambah Service Ujian
import '../../models/study_item.dart';
import '../../models/exam_item.dart';
import 'add_college_schedule_screen.dart';

class CollegeScheduleScreen extends StatefulWidget {
  const CollegeScheduleScreen({super.key});

  @override
  State<CollegeScheduleScreen> createState() => _CollegeScheduleScreenState();
}

class _CollegeScheduleScreenState extends State<CollegeScheduleScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  final ExamService _examService = ExamService(); // Service Ujian

  List<StudyItem> _classSchedules = [];
  List<ExamItem> _examSchedules = [];
  bool _isLoading = true;

  DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
    try {
      // Ambil Jadwal Kuliah & Ujian Sekaligus
      final classes = await _scheduleService.getSchedules();
      final exams = await _examService.getExams();

      if (mounted) {
        setState(() {
          _classSchedules = classes;
          _examSchedules = exams;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // LOGIKA PENGGABUNGAN JADWAL
  List<dynamic> _getEventsForSelectedDate() {
    // 1. Ambil Kuliah (Sesuai Hari Mingguan)
    int selectedDayOfWeek = _selectedDate.weekday;
    List<StudyItem> todaysClasses = _classSchedules.where((item) {
      return item.dayOfWeek == selectedDayOfWeek;
    }).toList();

    // 2. Ambil Ujian (Sesuai Tanggal Spesifik)
    List<ExamItem> todaysExams = _examSchedules.where((item) {
      return item.examDate.year == _selectedDate.year &&
          item.examDate.month == _selectedDate.month &&
          item.examDate.day == _selectedDate.day;
    }).toList();

    // 3. Gabung jadi satu list dynamic
    List<dynamic> allEvents = [...todaysClasses, ...todaysExams];

    // 4. Sort berdasarkan jam mulai
    allEvents.sort((a, b) {
      TimeOfDay timeA = (a is StudyItem)
          ? a.startTime
          : (a as ExamItem).startTime;
      TimeOfDay timeB = (b is StudyItem)
          ? b.startTime
          : (b as ExamItem).startTime;
      return (timeA.hour * 60 + timeA.minute).compareTo(
        timeB.hour * 60 + timeB.minute,
      );
    });

    return allEvents;
  }

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'id_ID';
    final events = _getEventsForSelectedDate();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Kalender Akademik',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // KALENDER HEADER
          _buildMonthHeader(),
          _buildDaySelector(),
          const Divider(height: 1, color: Colors.grey),

          // LIST JADWAL PURE
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : events.isEmpty
                ? const Center(
                    child: Text(
                      'Kosong. Tidak ada jadwal hari ini.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return _buildPureCard(event);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCollegeScheduleScreen()),
          );
          if (result == true) _fetchAllData();
        },
        backgroundColor: const Color(0xFF2ACDAB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // CARD MINIMALIS / PURE
  Widget _buildPureCard(dynamic event) {
    bool isExam = event is ExamItem;
    String title = isExam ? event.courseName : (event as StudyItem).name;
    String room = isExam
        ? "Lokasi Ujian"
        : (event as StudyItem).room; // Simplifikasi
    TimeOfDay start = isExam ? event.startTime : (event as StudyItem).startTime;
    TimeOfDay end = isExam ? event.endTime : (event as StudyItem).endTime;
    Color color = isExam ? Colors.redAccent : (event as StudyItem).color;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Indikator Warna & Jam
          Column(
            children: [
              Text(
                start.format(context),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                width: 2,
                height: 10,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(vertical: 2),
              ),
              Text(
                end.format(context),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Garis Warna
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 15),
          // Info Utama
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isExam)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "UJIAN",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      )
                    else
                      Text(
                        room,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets Header Kalender (Tetap sama) ---
  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(
              () => _selectedDate = _selectedDate.subtract(
                const Duration(days: 7),
              ),
            ),
          ),
          Text(
            DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(
              () => _selectedDate = _selectedDate.add(const Duration(days: 7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    DateTime startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          final isSelected =
              date.day == _selectedDate.day &&
              date.month == _selectedDate.month;
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2ACDAB)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'id_ID').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
