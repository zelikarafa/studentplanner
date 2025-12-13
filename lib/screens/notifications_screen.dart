import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // Contoh data Notifikasi
  final List<Map<String, dynamic>> notifications = const [
    // Today
    {'title': 'UTS Mobile Programming', 'details': 'Kelas akan dimulai 10 menit lagi!', 'time': '08:50 AM', 'color': Color(0xFF2ACDAB)},
    {'title': 'Tugas 1: UI/UX', 'details': 'Jatuh tempo hari ini! Segera kumpulkan!', 'time': '10:00 AM', 'color': Color(0xFFFFB300)},
    // Older
    {'title': 'Jadwal Baru', 'details': 'Jadwal Kuliah Semester Baru sudah rilis.', 'time': '2 days ago', 'color': Color(0xFF1E2749)},
    {'title': 'Pemrograman Mobile', 'details': 'Dosen menambahkan materi baru di LMS.', 'time': '1 week ago', 'color': Color(0xFF3B5998)},
    {'title': 'Selamat Datang!', 'details': 'Selamat datang di My Study Planner.', 'time': '1 month ago', 'color': Color(0xFF81C784)},
  ];

  @override
  Widget build(BuildContext context) {
    final todayNotifications = notifications.sublist(0, 2); // 2 notif pertama
    final olderNotifications = notifications.sublist(2); // Sisanya

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemberitahuan', style: TextStyle(color: Colors.black)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifikasi Hari Ini
            const Text('Today', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E2749))),
            const SizedBox(height: 15),
            ...todayNotifications.map((notif) => _buildNotificationCard(notif)).toList(),
            
            const SizedBox(height: 30),

            // Notifikasi Lama
            const Text('Older', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E2749))),
            const SizedBox(height: 15),
            ...olderNotifications.map((notif) => _buildNotificationCard(notif)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 60,
            decoration: BoxDecoration(
              color: notif['color'] as Color,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E2749),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  notif['details'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  notif['time'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }
}