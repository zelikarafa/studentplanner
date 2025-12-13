import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'schedule/college_schedule_screen.dart';
import 'schedule/exam_schedule_screen.dart'; // Pastikan impor ini ada
import 'tasks/tasks_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import '../models/task_item.dart'; // Import TaskStatus

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Daftar Layar untuk Navigasi Bawah
  final List<Widget> _screens = [
    const HomeContent(), // Isi Beranda
    Container(color: Colors.blue.shade50, child: const Center(child: Text("Kalender"))), // Placeholder Kalender
    // FIX: Menggunakan TaskStatus.to_do yang benar
    TasksScreen(initialStatus: TaskStatus.to_do), // Arahkan ke Layar Tugas
    const NotificationsScreen(), // Layar Pemberitahuan
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// Isi Layar Beranda
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hi, Name!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2749),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                  child: const CircleAvatar(
                    // backgroundImage: AssetImage('assets/profile_pic.png'), 
                    radius: 20,
                    child: Icon(Icons.person, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildMenuItem(
                  context,
                  title: 'Jadwal Kuliah',
                  icon: Icons.book,
                  color: const Color(0xFFFEE8BD),
                  iconColor: const Color(0xFFE99C0D),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CollegeScheduleScreen()), 
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildMenuItem(
                  context,
                  title: 'Jadwal Ujian',
                  icon: Icons.school,
                  color: const Color(0xFFDDFFD2),
                  iconColor: const Color(0xFF389B03),
                  onTap: () {
                    // FIX: ExamScheduleScreen() sudah dipanggil dengan benar
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ExamScheduleScreen()), 
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildMenuItem(
                  context,
                  title: 'Tugas',
                  icon: Icons.assignment,
                  color: const Color(0xFFE0E0FF),
                  iconColor: const Color(0xFF6B4EE6),
                  onTap: () {
                    // Pindah ke tab Tugas di Bottom Nav Bar (indeks 2)
                    (context.findAncestorStateOfType<_HomeScreenState>()?._onItemTapped(2)); 
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              // Penggunaan withOpacity(0.1) sudah benar
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(icon, size: 30, color: iconColor),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E2749),
              ),
            ),
          ],
        ),
      ),
    );
  }
}