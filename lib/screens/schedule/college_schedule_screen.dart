import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../../main.dart'; 
import 'add_college_schedule_screen.dart'; // Import AddCollegeScheduleScreen yang asli
import '../../models/study_item.dart';
import '../../widgets/bottom_nav_bar.dart'; 

class CollegeScheduleScreen extends StatefulWidget {
  const CollegeScheduleScreen({super.key});

  @override
  State<CollegeScheduleScreen> createState() => _CollegeScheduleScreenState();
}

class _CollegeScheduleScreenState extends State<CollegeScheduleScreen> {
  DateTime _currentDate = DateTime.now(); 
  DateTime _selectedDate = DateTime.now(); 

  int _selectedIndex = 0; 

  void _onItemTapped(int index) {
    // Navigasi ke halaman utama jika index 0, atau pop untuk navigasi lain
    if (index == 0) {
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      // Di sini Anda mungkin ingin menavigasi ke halaman lain
      // Misalnya, jika index 1 adalah halaman 'Ujian', maka navigasi ke halaman Ujian.
    }
  }

  // Fungsi untuk memfilter dan mengurutkan jadwal
  List<StudyItem> _getTodaysSchedules() {
    // Variabel ini tidak digunakan di sini, tapi dipertahankan jika Anda ingin
    // menambahkan filter hari di masa mendatang.
    // final int selectedDayOfWeek = _selectedDate.weekday; 

    List<StudyItem> schedules = AppData.collegeSchedules;
    
    // Urutkan berdasarkan waktu mulai (PENTING)
    schedules.sort((a, b) {
      int timeA = a.startTime.hour * 60 + a.startTime.minute;
      int timeB = b.startTime.hour * 60 + b.startTime.minute;
      return timeA.compareTo(timeB);
    });

    return schedules;
  }
  
  @override
  Widget build(BuildContext context) {
    // Set locale untuk DateFormat
    Intl.defaultLocale = 'id_ID';

    final List<StudyItem> schedules = _getTodaysSchedules();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Kuliah', style: TextStyle(color: Colors.black)),
        centerTitle: true,
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
          Column(
            children: [
              _buildMonthHeader(),
              _buildDaySelector(),
              const Divider(height: 1, color: Colors.grey),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        'Jadwal Kuliah Hari ${DateFormat('EEEE', 'id_ID').format(_selectedDate)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      // Render Jadwal
                      ..._buildTimelineSchedule(schedules),
                      const SizedBox(height: 100), // Padding agar konten tidak tertutup tombol
                    ],
                  ),
                ),
              ),
            ],
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
                    // Mengarah ke AddCollegeScheduleScreen yang sudah diimport
                    MaterialPageRoute(builder: (context) => const AddCollegeScheduleScreen()),
                  );
                  // Refresh state setelah kembali dari layar tambah
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
                        offset: const Offset(0, 3),
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
          // --------------------------------------------------------
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex, 
        onItemTapped: _onItemTapped, 
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Text(
            DateFormat('MMMM', 'id_ID').format(_currentDate), 
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
                icon: const Icon(Icons.arrow_back, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _currentDate = DateTime(_currentDate.year, _currentDate.month, _currentDate.day - 7);
                    _selectedDate = _currentDate; 
                  });
                },
              ),
              Text(
                DateFormat('yyyy').format(_currentDate), 
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.grey),
                onPressed: () {
                    setState(() {
                    _currentDate = DateTime(_currentDate.year, _currentDate.month, _currentDate.day + 7);
                    _selectedDate = _currentDate; 
                    });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    // Kita buat list 7 hari mulai dari hari Senin dari minggu yang dipilih
    DateTime startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 17, // Cukup 7 hari untuk representasi mingguan
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          
          final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month && date.year == _selectedDate.year;

          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 24.0 : 8.0, right: index == 6 ? 24.0 : 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date; 
                });
              },
              child: Container(
                width: 55,
                height: 80,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2ACDAB) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: isSelected
                      ? [
                            BoxShadow(
                              color: const Color(0xFF2ACDAB).withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            )
                          ]
                      : null,
                  border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('EEE', 'id_ID').format(date), 
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontSize: 14,
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

  // Mengganti _buildScheduleTimes menjadi _buildTimelineSchedule untuk timeline yang lebih baik
  List<Widget> _buildTimelineSchedule(List<StudyItem> schedules) {
    List<Widget> scheduleWidgets = [];
    final int startHour = 7; // Mulai jam 7 pagi
    final int endHour = 18; // Sampai jam 6 sore (18:00)

    // Jika tidak ada jadwal sama sekali
    if (schedules.isEmpty) {
        scheduleWidgets.add(
            const Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: Center(
                    child: Text(
                        'Tidak ada jadwal kuliah yang ditambahkan.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                ),
            )
        );
        return scheduleWidgets;
    }

    Set<StudyItem> processedSchedules = {};

    for (int i = startHour; i <= endHour; i++) {
      // PERBAIKAN: Menggunakan TimeOfDay untuk pemformatan waktu
      TimeOfDay timeAnchor = TimeOfDay(hour: i, minute: 0); 
      final materialLocalizations = MaterialLocalizations.of(context);
      
      // Menggunakan formatTimeOfDay untuk mendapatkan label waktu yang benar (e.g. 9:00 AM)
      String formattedTime = materialLocalizations.formatTimeOfDay(timeAnchor, alwaysUse24HourFormat: false);
      
      // Memangkas label waktu (e.g., dari "9:00 AM" menjadi "9AM")
      String timeLabel = formattedTime.replaceAll(':00', '').replaceAll(' ', '');
      if (timeLabel.endsWith('AM') || timeLabel.endsWith('PM')) {
        timeLabel = timeLabel.replaceAll(' ', '');
      } else {
        timeLabel = formattedTime.split(':').first;
      }


      List<StudyItem> itemsAtTime = schedules.where((e) {
        // Cek apakah item dimulai di jam ini dan belum diproses (untuk menghindari duplikasi)
        return !processedSchedules.contains(e) && e.startTime.hour == i;
      }).toList();

      scheduleWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  timeLabel, // Menggunakan label waktu yang sudah diformat
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: itemsAtTime.map((item) {
                    processedSchedules.add(item); 
                    return _buildScheduleCard(item);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
      
      // Garis pemisah antar jam
      if (i < endHour) {
        scheduleWidgets.add(
          const Padding(
            padding: EdgeInsets.only(left: 60),
            child: Divider(color: Colors.grey),
          ),
        );
      }
    }

    return scheduleWidgets;
  }

  Widget _buildScheduleCard(StudyItem item) {
    // Menggunakan MaterialLocalizations untuk format waktu yang konsisten
    String formatTime(TimeOfDay time) {
        final materialLocalizations = MaterialLocalizations.of(context);
        return materialLocalizations.formatTimeOfDay(time, alwaysUse24HourFormat: false);
    }

    String timeRange = '${formatTime(item.startTime)} - ${formatTime(item.endTime)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
           // PERBAIKAN: BoxShadow tidak boleh const karena menggunakan item.color
           BoxShadow(
            // PERBAIKAN: Ganti 'withOpacity' yang deprecated (jika ada)
            color: item.color.withOpacity(0.3), 
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Waktu: $timeRange',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Nama Dosen: ${item.lecturerName}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Ruangan: ${item.room}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fitur Edit ${item.name} belum diimplementasikan.')),
                  );
                },
                child: const Icon(Icons.edit, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  // Logika hapus
                  setState(() {
                    AppData.collegeSchedules.remove(item);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.name} dihapus.')),
                  );
                },
                child: const Icon(Icons.delete, color: Colors.white, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}