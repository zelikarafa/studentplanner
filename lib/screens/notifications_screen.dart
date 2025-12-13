import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/task_service.dart';
import '../services/schedule_service.dart'; // Import Schedule Service
import '../models/study_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _taskService = TaskService();
  final _scheduleService = ScheduleService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    List<Map<String, dynamic>> tempAlerts = [];
    final now = DateTime.now();

    try {
      // 1. CEK TUGAS (Deadline H-5 s/d Hari H)
      final tasks = await _taskService.getTasks();
      for (var t in tasks) {
        if (!t.isCompleted) {
          final diff = t.deadline.difference(now).inDays;

          if (diff >= 0 && diff <= 5) {
            tempAlerts.add({
              'type': 'Tugas',
              'title': 'Deadline: ${t.title}',
              'details':
                  '${t.courseName} - ${diff == 0 ? "Hari ini!" : "$diff hari lagi"}',
              'time': DateFormat('HH:mm').format(t.deadline),
              'date': t.deadline, // Untuk sorting
              'color': Colors.orange,
              'icon': Icons.assignment_late_outlined,
            });
          }
        }
      }

      // 2. CEK JADWAL KULIAH HARI INI (Reminder 1 Jam Sebelum)
      // Logika: Ambil jadwal hari ini yang jam mulainya > jam sekarang (belum lewat)
      final schedules = await _scheduleService.getSchedules();
      final todayWeekday = now.weekday;

      for (var s in schedules) {
        if (s.dayOfWeek == todayWeekday) {
          // Buat DateTime hari ini dengan jam mulai jadwal
          final classTime = DateTime(
            now.year,
            now.month,
            now.day,
            s.startTime.hour,
            s.startTime.minute,
          );
          final diffInMinutes = classTime.difference(now).inMinutes;

          // Tampilkan jika kelas belum dimulai DAN akan mulai dalam < 3 jam (Reminder)
          // Atau tampilkan semua kelas hari ini yang belum selesai
          if (diffInMinutes > -30) {
            // Tampilkan jika belum lewat 30 menit dari jam masuk
            String timeLabel = "Segera";
            if (diffInMinutes > 60)
              timeLabel = "${(diffInMinutes / 60).floor()} jam lagi";
            else if (diffInMinutes > 0)
              timeLabel = "$diffInMinutes menit lagi";
            else
              timeLabel = "Sedang Berlangsung";

            tempAlerts.add({
              'type': 'Kelas',
              'title': 'Kelas: ${s.name}',
              'details': 'Ruang ${s.room} • $timeLabel',
              'time': s.startTime.format(context),
              'date': classTime,
              'color': const Color(0xFF2ACDAB),
              'icon': Icons.class_outlined,
            });
          }
        }
      }

      // Sort berdasarkan waktu (paling dekat paling atas)
      tempAlerts.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
      );

      if (mounted) {
        setState(() {
          _alerts = tempAlerts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pemberitahuan',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alerts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Tidak ada notifikasi baru.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _alerts.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final notif = _alerts[index];
                return _buildNotificationCard(notif);
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (notif['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(notif['icon'], color: notif['color']),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notif['type'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: notif['color'],
                      ),
                    ),
                    Text(
                      notif['time'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  notif['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E2749),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  notif['details'],
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
