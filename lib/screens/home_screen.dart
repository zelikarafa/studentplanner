import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import Layanan & Model
import '../services/home_schedule_service.dart';
import '../models/study_item.dart';
import '../models/exam_item.dart';

import '../widgets/bottom_nav_bar.dart';

// IMPORT HALAMAN
import 'schedule/college_schedule_screen.dart';
// Import baru: ClassScheduleListScreen untuk List Jadwal Kelas
import 'schedule/class_schedule_list_screen.dart';
import 'exams/exam_screen.dart';
import 'tasks/tasks_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // DAFTAR HALAMAN (3 Tab Utama)
  final List<Widget> _screens = [
    // Tab 0: HomeContent
    const HomeContent(),
    // Tab 1: Kalender Akademik
    const CollegeScheduleScreen(),
    // Tab 2: Notifikasi
    const NotificationsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// =======================================================
// WIDGET ISI BERANDA (CLEAN MODE)
// =======================================================
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final _supabase = Supabase.instance.client;
  final HomeScheduleService _homeScheduleService = HomeScheduleService();
  String _userName = 'Mahasiswa';

  // State untuk Jadwal Harian
  List<dynamic> _todaysEvents = [];
  bool _isLoadingSchedule = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _fetchTodaysSchedule();
  }

  // --- LOGIKA DATA ---

  Future<void> _loadProfile() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final data = await _supabase
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();

        // Fix curly_braces_in_flow_control_structures warning
        if (data != null && mounted) {
          setState(() {
            // Menggunakan ?? untuk memastikan _userName non-nullable
            _userName = data['full_name'] ?? 'Mahasiswa';
          });
        }
      } catch (e) {
        debugPrint('Error loading profile: $e');
      }
    }
  }

  Future<void> _fetchTodaysSchedule() async {
    setState(() => _isLoadingSchedule = true);
    try {
      final events = await _homeScheduleService.getTodaysEvents();
      if (mounted) {
        setState(() {
          _todaysEvents = events;
          _isLoadingSchedule = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching today's schedule: $e");
      if (mounted) setState(() => _isLoadingSchedule = false);
    }
  }

  // --- WIDGET BUILDER ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _fetchTodaysSchedule,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER HIJAU
              _buildHeader(context),

              const SizedBox(height: 40),

              // MENU GRID
              _buildMenuGrid(context),

              const SizedBox(height: 30),

              // JADWAL HARI INI (PREVIEW)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Jadwal Hari Ini',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2749),
                      ),
                    ),
                    // Tombol Lihat Semua -> Pindah ke tab Kalender Akademik (Index 1)
                    TextButton(
                      onPressed: () => context
                          .findAncestorStateOfType<_HomeScreenState>()
                          ?._onItemTapped(1),
                      child: const Text(
                        'Lihat Semua >',
                        style: TextStyle(color: Color(0xFF2ACDAB)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // LIST JADWAL HARI INI
              _buildSchedulePreview(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF2ACDAB), // Hijau utama
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat Datang,',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                _userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    // Navigasi Tab Bar (untuk 'Lihat Semua' di bawah)
    // final parentTapped = context.findAncestorStateOfType<_HomeScreenState>()?._onItemTapped;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. JADWAL (Navigasi ke Daftar List Jadwal Kelas)
          _buildBigMenu(
            'Jadwal',
            Icons.calendar_today,
            const Color(0xFFE3F2FD),
            const Color(0xFF42A5F5),
            // PERBAIKAN NAVIGASI: Pindah ke ClassScheduleListScreen
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ClassScheduleListScreen(),
              ),
            ),
          ),

          // 2. TUGAS (Buka Halaman)
          _buildBigMenu(
            'Tugas',
            Icons.assignment,
            const Color(0xFFFFF3E0),
            const Color(0xFFFFA726),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TasksScreen()),
            ),
          ),

          // 3. UJIAN (Buka Halaman)
          _buildBigMenu(
            'Ujian',
            Icons.school,
            const Color(0xFFFBEBF0),
            const Color(0xFFEF5350),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExamScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBigMenu(
    String title,
    IconData icon,
    Color bg,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    // Fix: Mengatasi 'withOpacity' is deprecated
                    color: Colors.grey.withAlpha((255 * 0.1).round()),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(child: Icon(icon, size: 40, color: iconColor)),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF1E2749),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulePreview() {
    if (_isLoadingSchedule) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: Color(0xFF2ACDAB)),
        ),
      );
    }

    if (_todaysEvents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            "Tidak ada kelas atau ujian terjadwal hari ini.",
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final displayEvents = _todaysEvents.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: displayEvents.map((event) {
          // Fix: Menggunakan Type Promotion untuk menghilangkan warnings:
          // Dead Code, Unnecessary Cast, dan Null-Aware warnings.
          String title;
          TimeOfDay time;
          String room;
          bool isExam;

          if (event is ExamItem) {
            title = event.courseName ?? 'Ujian Tanpa Nama';
            time = event.startTime;
            room = event.room ?? 'Offline';
            isExam = true;
          } else if (event is StudyItem) {
            title = event.name ?? 'Kuliah Tanpa Nama';
            time = event.startTime;
            room = event.room ?? 'Online';
            isExam = false;
          } else {
            return const SizedBox.shrink();
          }

          return _buildEventCard(
            title: title,
            time: time,
            room: room,
            isExam: isExam,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventCard({
    required String title,
    required TimeOfDay time,
    required String room,
    required bool isExam,
  }) {
    final themeColor = isExam ? Colors.redAccent : const Color(0xFF2ACDAB);
    final icon = isExam ? Icons.school_outlined : Icons.menu_book_sharp;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        // Fix: Mengatasi 'withOpacity' is deprecated
        border: Border.all(color: themeColor.withAlpha((255 * 0.1).round())),
        boxShadow: [
          BoxShadow(
            // Fix: Mengatasi 'withOpacity' is deprecated
            color: Colors.grey.withAlpha((255 * 0.1).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon & Waktu
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // Fix: Mengatasi 'withOpacity' is deprecated
              color: themeColor.withAlpha((255 * 0.1).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: themeColor, size: 24),
          ),
          const SizedBox(width: 15),

          // Detail Acara
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E2749),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      time.format(context),
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      room,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
}
