import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/bottom_nav_bar.dart';

// IMPORT HALAMAN
import 'schedule/college_schedule_screen.dart';
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
    const HomeContent(),
    const CollegeScheduleScreen(),
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
  String _userName = 'Mahasiswa';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final data = await _supabase
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();
        if (data != null && mounted)
          setState(() => _userName = data['full_name'] ?? 'Mahasiswa');
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER HIJAU
            Container(
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
            ),

            const SizedBox(height: 40),

            // MENU GRID (Hanya ini isinya)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. JADWAL (Pindah Tab)
                  _buildBigMenu(
                    context,
                    'Jadwal',
                    Icons.calendar_today,
                    const Color(0xFFFFF3E0),
                    const Color(0xFFFFA726),
                    1,
                  ),

                  // 2. TUGAS (Buka Halaman)
                  _buildBigMenu(
                    context,
                    'Tugas',
                    Icons.assignment,
                    const Color(0xFFE3F2FD),
                    const Color(0xFF42A5F5),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TasksScreen()),
                      );
                    },
                  ),

                  // 3. UJIAN (Buka Halaman)
                  _buildBigMenu(
                    context,
                    'Ujian',
                    Icons.school,
                    const Color(0xFFE8F5E9),
                    const Color(0xFF66BB6A),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ExamScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigMenu(
    BuildContext context,
    String title,
    IconData icon,
    Color bg,
    Color iconColor,
    dynamic target,
  ) {
    return InkWell(
      onTap: () {
        if (target is int) {
          context.findAncestorStateOfType<_HomeScreenState>()?._onItemTapped(
            target,
          );
        } else if (target is Function) {
          target();
        }
      },
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90, // Lebih besar biar enak ditekan
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1E2749),
            ),
          ),
        ],
      ),
    );
  }
}
