import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Import Service & Model
import '../../services/schedule_service.dart';
import '../../services/exam_service.dart';
import '../../models/study_item.dart';
import '../../models/exam_item.dart';
// import 'add_college_schedule_screen.dart'; // HAPUS: Unused import sudah dihapus

class CollegeScheduleScreen extends StatefulWidget {
  const CollegeScheduleScreen({super.key});

  @override
  State<CollegeScheduleScreen> createState() => _CollegeScheduleScreenState();
}

class _CollegeScheduleScreenState extends State<CollegeScheduleScreen> {
  // Services
  final ScheduleService _scheduleService = ScheduleService();
  final ExamService _examService = ExamService();

  // Controller untuk mengontrol posisi scroll horizontal hari
  final ScrollController _scrollController = ScrollController();

  // Data Storage
  List<StudyItem> _classSchedules = []; // Jadwal Kuliah (Mingguan)
  List<ExamItem> _examSchedules = []; // Jadwal Ujian (Tanggal Spesifik)

  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now(); // Tanggal yang dipilih di kalender

  @override
  void initState() {
    super.initState();
    _fetchAllData();
    // Panggil scroll setelah frame pertama selesai digambar
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedDay());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 1. AMBIL DATA KELAS & UJIAN SEKALIGUS
  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
    try {
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
      // Menggunakan debugPrint agar tidak crash di production mode
      debugPrint("Error fetching calendar data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. LOGIKA GANTI BULAN
  void _changeMonth(int offset) {
    setState(() {
      // Pindahkan ke tanggal 1 bulan baru, lalu tetapkan tanggal yang dipilih ke 1.
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + offset,
        1,
      );
    });
    // Scroll otomatis ke tanggal 1 setelah ganti bulan
    _scrollToSelectedDay();
  }

  // 3. LOGIKA SCROLL KE TANGGAL YANG DIPILIH
  void _scrollToSelectedDay() {
    // Scroll hanya jika ListView sudah dimuat dan ScrollController melekat
    if (_scrollController.hasClients) {
      final selectedDayIndex = _selectedDate.day - 1;
      const itemWidth = 55.0;
      const itemMargin = 8.0;

      final offset =
          (selectedDayIndex * (itemWidth + itemMargin)) -
          (MediaQuery.of(context).size.width / 2) +
          (itemWidth / 2);

      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // 4. LOGIKA PENGGABUNGAN (JANTUNGNYA FITUR INI)
  // Fixes: Unnecessary Cast and Dead Code in sort logic.
  List<dynamic> _getEventsForSelectedDate() {
    int selectedDayOfWeek = _selectedDate.weekday;
    List<dynamic> todaysEvents = [];

    // A. Filter Kelas (Berdasarkan HARI dalam seminggu)
    for (var cls in _classSchedules) {
      if (cls.dayOfWeek == selectedDayOfWeek) {
        todaysEvents.add(cls);
      }
    }

    // B. Filter Ujian (Berdasarkan TANGGAL persis)
    for (var exam in _examSchedules) {
      if (exam.examDate.year == _selectedDate.year &&
          exam.examDate.month == _selectedDate.month &&
          exam.examDate.day == _selectedDate.day) {
        todaysEvents.add(exam);
      }
    }

    // C. Urutkan berdasarkan Jam Mulai
    todaysEvents.sort((a, b) {
      // Gunakan Type Promotion agar Dart Smart Cast bisa bekerja,
      // menghilangkan warning 'Unnecessary cast' dan 'Dead code'.
      TimeOfDay timeA;
      TimeOfDay timeB;

      if (a is StudyItem) {
        timeA = a.startTime;
      } else if (a is ExamItem) {
        timeA = a.startTime;
      } else {
        // Fallback jika tipe tidak terduga, ini menghindari potential Dead Code.
        timeA = const TimeOfDay(hour: 0, minute: 0);
      }

      if (b is StudyItem) {
        timeB = b.startTime;
      } else if (b is ExamItem) {
        timeB = b.startTime;
      } else {
        timeB = const TimeOfDay(hour: 0, minute: 0); // Fallback
      }

      int minutesA = timeA.hour * 60 + timeA.minute;
      int minutesB = timeB.hour * 60 + timeB.minute;
      return minutesA.compareTo(minutesB);
    });

    return todaysEvents;
  }

  @override
  Widget build(BuildContext context) {
    // Set locale ID biar tanggal jadi bahasa Indonesia (Senin, Selasa...)
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
        // Pastikan tombol back tidak otomatis muncul jika layar ini adalah Tab Utama
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // --- HEADER KALENDER ---
          _buildMonthSelector(),
          _buildDaySelector(),
          const Divider(height: 1),

          // --- LIST JADWAL ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    // Tambahkan RefreshIndicator untuk memuat ulang data
                    onRefresh: _fetchAllData,
                    child: events.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              // Pengecekan tipe data yang bersih
                              if (event is ExamItem || event is StudyItem) {
                                return _buildDetailCard(
                                  event,
                                  isExam: event is ExamItem,
                                );
                              } else {
                                // Penanganan jika ada tipe data yang tidak terduga
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: KARTU DETAIL ---
  Widget _buildDetailCard(dynamic item, {required bool isExam}) {
    // Fixes: Null Safety Warnings (A value of type 'String?' can't be as...)
    // Fixes: Dead Code Warnings (karena `else { return const SizedBox.shrink(); }` sekarang pasti tercapai jika tipe tidak sesuai).
    String title;
    String room;
    String details;
    TimeOfDay start;
    TimeOfDay end;

    if (item is ExamItem) {
      // Menggunakan ?? untuk menangani String? dan memastikan output adalah String non-nullable
      title = item.courseName ?? 'Ujian Tanpa Nama';
      room = item.room ?? 'Offline';
      details = item.details ?? '';
      start = item.startTime; // Asumsi non-nullable di Model
      end = item.endTime; // Asumsi non-nullable di Model
    } else if (item is StudyItem) {
      // Menggunakan ?? untuk menangani String? dan memastikan output adalah String non-nullable
      title = item.name ?? 'Kelas Tanpa Nama';
      room = item.room ?? 'Online';
      details = item.details ?? '';
      start = item.startTime; // Asumsi non-nullable di Model
      end = item.endTime; // Asumsi non-nullable di Model
    } else {
      // Jika item bukan salah satu tipe yang diharapkan, return widget kosong.
      return const SizedBox.shrink();
    }

    String label = isExam ? "UJIAN" : "KULIAH";
    Color themeColor = isExam ? Colors.redAccent : const Color(0xFF2ACDAB);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        // Fixes: 'withOpacity' is deprecated. Menggunakan withAlpha()
        border: Border.all(color: themeColor.withAlpha((255 * 0.3).round())),
        boxShadow: [
          BoxShadow(
            color: themeColor.withAlpha((255 * 0.1).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Strip Warna Kiri
          Container(
            width: 6,
            height: 100,
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
          ),

          // 2. Konten Utama (Waktu)
          SizedBox(
            width: 85,
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  start.format(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  end.format(context),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // 3. Detail Mata Kuliah
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Matkul
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Detail: Ruangan
                  Row(
                    children: [
                      Icon(Icons.room, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          room.isEmpty ? "Online/Lainnya" : room,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Label UJIAN/KULIAH dan Detail Tambahan
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor.withAlpha((255 * 0.1).round()),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: themeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      if (details.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            details,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER LAINNYA ---

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 60,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 10),
                Text(
                  "Tidak ada jadwal hari ini.",
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(height: 20),
                Text(
                  "Tarik ke bawah untuk memuat ulang data.",
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget Pilih Bulan (Header)
  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            // Panggil _changeMonth(-1) untuk Mundur
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            // Panggil _changeMonth(1) untuk Maju
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  // Widget Pilih Hari (Horizontal List - FULL BULAN + Auto Scroll)
  Widget _buildDaySelector() {
    // 1. Hitung total hari dalam bulan yang dipilih
    final daysInMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    ).day;

    return SizedBox(
      height: 90,
      child: ListView.builder(
        controller: _scrollController, // Gunakan controller
        scrollDirection: Axis.horizontal,
        itemCount: daysInMonth, // Tampilkan dari tgl 1 sampai 30/31
        itemBuilder: (context, index) {
          // index 0 = tanggal 1
          final dayNum = index + 1;
          final date = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            dayNum,
          );

          final isSelected = dayNum == _selectedDate.day;

          final now = DateTime.now();
          final isToday =
              date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              // Scroll ke tengah saat diklik
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _scrollToSelectedDay(),
              );
            },
            child: Container(
              width: 55,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2ACDAB)
                    : (isToday ? Colors.grey[100] : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat(
                      'E',
                      'id_ID',
                    ).format(date), // Nama Hari (Sen, Sel...)
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${date.day}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  if (isToday && !isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2ACDAB),
                        shape: BoxShape.circle,
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
