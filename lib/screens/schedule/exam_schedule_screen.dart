// lib/screens/schedule/exam_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Sesuaikan path import AddExamScheduleScreen
import 'add_exam_schedule_screen.dart'; 
// Sesuaikan path import main.dart (AppData)
import '../../main.dart'; 
import '../../models/study_item.dart';
// Sesuaikan path import bottom_nav_bar.dart
import '../../widgets/bottom_nav_bar.dart'; 


class ExamScheduleScreen extends StatefulWidget {
  const ExamScheduleScreen({super.key});

  @override
  State<ExamScheduleScreen> createState() => _ExamScheduleScreenState();
}

class _ExamScheduleScreenState extends State<ExamScheduleScreen> {
  DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 0) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Fungsi untuk mendapatkan semua ujian pada tanggal yang dipilih
  List<StudyItem> _getTodaysExams() {
    final List<StudyItem> todaysExams = AppData.examSchedules.where((exam) {
      if (exam.examDate == null) return false;
      return exam.examDate!.year == _selectedDate.year &&
          exam.examDate!.month == _selectedDate.month &&
          exam.examDate!.day == _selectedDate.day;
    }).toList();

    // Pastikan diurutkan berdasarkan waktu mulai (PENTING!)
    todaysExams.sort((a, b) {
      int timeA = a.startTime.hour * 60 + a.startTime.minute;
      int timeB = b.startTime.hour * 60 + b.startTime.minute;
      return timeA.compareTo(timeB);
    });

    return todaysExams;
  }

  @override
  Widget build(BuildContext context) {
    final todaysExams = _getTodaysExams();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Ujian', style: TextStyle(color: Colors.black)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.person, color: Colors.black),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMonthNavigation(),
                _buildDateSelector(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: Text(
                    'Jadwal Ujian',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2749),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: _buildTimelineSchedule(todaysExams), // Menggunakan logika timeline baru
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          // --- Tombol Tambah di Kanan Bawah ---
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 24.0, bottom: 20.0),
              child: InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddExamScheduleScreen()),
                  );
                  // Refresh UI setelah kembali dari penambahan jadwal
                  setState(() {}); 
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF2ACDAB), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Color(0xFF2ACDAB), size: 20),
                      SizedBox(width: 5),
                      Text(
                        'Tambah',
                        style: TextStyle(
                          color: Color(0xFF2ACDAB),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
      child: Column(
        children: [
          Text(
            DateFormat('MMMM').format(_currentDate),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2749),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, _currentDate.day);
                    // Pastikan selectedDate masih dalam bulan yang sama, atau set ke hari pertama bulan baru
                    _selectedDate = DateTime(_currentDate.year, _currentDate.month, 1);
                  });
                },
              ),
              Text(
                DateFormat('yyyy').format(_currentDate),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  setState(() {
                    _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, _currentDate.day);
                    // Pastikan selectedDate masih dalam bulan yang sama, atau set ke hari pertama bulan baru
                    _selectedDate = DateTime(_currentDate.year, _currentDate.month, 1);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    DateTime startOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    DateTime endOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0);

    List<DateTime> daysInMonth = [];
    for (int i = 0; i < endOfMonth.day; i++) {
        daysInMonth.add(startOfMonth.add(Duration(days: i)));
    }
    
    // Kita hanya menampilkan hari-hari dalam seminggu yang dipilih, 
    // atau jika Anda ingin menampilkan bulan penuh, logika ini perlu diubah.
    // Saat ini, kita tetap menggunakan tampilan mingguan untuk menjaga konsistensi UI Anda.
    
    DateTime startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    // Jika minggu ini berada di bulan sebelumnya/berikutnya, sesuaikan agar tetap di bulan yang sedang ditampilkan
    if (startOfWeek.month != _currentDate.month && startOfWeek.add(const Duration(days: 6)).month == _currentDate.month) {
        startOfWeek = DateTime(_currentDate.year, _currentDate.month, 1);
    }


    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 17,
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          
          if (date.month != _currentDate.month) {
            // Jika tanggal di luar bulan saat ini (misalnya awal bulan), tampilkan kotak kosong
            return const SizedBox(width: 60 + 8.0 * 2);
          }
          
          final hasExam = AppData.examSchedules.any((exam) => 
            exam.examDate != null && 
            exam.examDate!.year == date.year && 
            exam.examDate!.month == date.month && 
            exam.examDate!.day == date.day
          );
          
          final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month && date.year == _selectedDate.year;

          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 24.0 : 8.0, right: index == 6 ? 24.0 : 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                  _currentDate = date;
                });
              },
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2ACDAB) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: isSelected ? const Color(0xFF2ACDAB) : Colors.grey.shade300, width: 1),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2ACDAB).withOpacity(0.3), 
                            spreadRadius: 1,
                            blurRadius: 5,
                          )
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(date),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasExam && !isSelected) // Tanda kecil jika ada ujian, kecuali saat dipilih
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- LOGIKA BARU UNTUK MENGELOMPOKKAN JADWAL UJIAN BERDASARKAN WAKTU ---
  List<Widget> _buildTimelineSchedule(List<StudyItem> exams) {
    if (exams.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: Text(
              'Tidak ada jadwal ujian untuk hari ini.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        )
      ];
    }
    
    List<Widget> scheduleWidgets = [];
    final int startHour = 8;
    final int endHour = 17;
    
    // Peta untuk menyimpan jadwal yang sudah diproses agar tidak duplikasi
    Set<StudyItem> processedExams = {};
    
    for (int i = startHour; i <= endHour; i++) {
      DateTime timeAnchor = DateTime(0, 0, 0, i);
      String timeLabel = DateFormat('h a').format(timeAnchor); 
      
      // Ambil semua ujian yang dimulai pada jam ini atau belum diproses dan mulai di antara jam ini dan jam berikutnya
      List<StudyItem> itemsAtTime = exams.where((e) {
        return !processedExams.contains(e) && e.startTime.hour == i;
      }).toList();

      if (itemsAtTime.isNotEmpty) {
         // Sortir ulang item yang ditemukan, meskipun sudah disortir di _getTodaysExams
         itemsAtTime.sort((a, b) => (a.startTime.hour * 60 + a.startTime.minute).compareTo(b.startTime.hour * 60 + b.startTime.minute));

        scheduleWidgets.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 50,
                child: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Text(
                    timeLabel,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: itemsAtTime.map((item) {
                    processedExams.add(item); // Tandai sudah diproses
                    return _buildExamItem(context, item);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      } else {
         // Jika tidak ada item pada jam tersebut, hanya tampilkan garis putus-putus 
         // untuk menjaga struktur timeline per jam.
          scheduleWidgets.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text(
                      timeLabel,
                      style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          );
      }
      
      // Garis Putus-Putus
      if (i < endHour) {
        scheduleWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 60, bottom: 8.0, top: 8.0),
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width - 24.0*2 - 60, 1),
              painter: DottedLinePainter(),
            ),
          ),
        );
      }
    }
    
    return scheduleWidgets;
  }
  
  Widget _buildExamItem(BuildContext context, StudyItem exam) {
    String timeRange = '${exam.startTime.format(context)} - ${exam.endTime.format(context)}';
    
    return Container(
      // Margin bawah disesuaikan agar item rapat di bawah label jam
      margin: const EdgeInsets.only(bottom: 10), 
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: exam.color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: exam.color.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exam.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Waktu: $timeRange',
            style: const TextStyle(color: Colors.white70, fontSize: 12)
          ),
          if (exam.details != null && exam.details!.isNotEmpty)
            Text(
              'Keterangan: ${exam.details}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)
            ),
          Text(
            'Ruangan: ${exam.room}',
            style: const TextStyle(color: Colors.white70, fontSize: 12)
          ),
        ],
      ),
    );
  }
}


// --- CustomPainter untuk Garis Putus-Putus (Dotted Line) ---

class DottedLinePainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint() 
      ..color = Colors.grey.shade300 // Warna garis putus-putus lebih lembut
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    const double dashWidth = 4.0;
    const double dashSpace = 4.0;
    double startX = 0.0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DottedLinePainter oldDelegate) => false;
}