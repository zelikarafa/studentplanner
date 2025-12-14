import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// PASTIKAN PATH INI SUDAH BENAR SESUAI STRUKTUR FOLDER ANDA
import '../services/task_service.dart';
import '../services/schedule_service.dart';
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
  // Menggunakan List<dynamic> karena berisi data Map
  List<Map<String, dynamic>> _alerts = [];

  @override
  void initState() {
    super.initState();
    // Set locale ke Indonesia untuk format TimeOfDay (HH:mm)
    Intl.defaultLocale = 'id_ID';
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
        // Cek hanya tugas yang belum Selesai
        if (t.status != 'Selesai') {
          // Jarak waktu sampai deadline
          final diff = t.deadline.difference(now);
          final diffInDays = diff.inDays;

          // Tampilkan jika deadline <= 5 hari atau jika deadline sudah lewat
          // (diffInDays negatif), tapi belum lebih dari 7 hari (agar tidak menumpuk)
          if (diffInDays >= -7 && diffInDays <= 5) {
            // Tentukan label waktu
            String timeLabel;
            Color taskColor;
            IconData taskIcon = Icons.assignment_late_outlined;

            if (diffInDays < 0) {
              // Lewat Deadline (Missed)
              timeLabel = "LEWAT TENGGAT";
              taskColor = Colors.red.shade700;
              taskIcon = Icons.cancel_outlined;
            } else if (diffInDays == 0) {
              // Hari H
              timeLabel = "Hari ini!";
              taskColor = Colors.red;
            } else {
              // H-1 sampai H-5
              timeLabel = "$diffInDays hari lagi";
              taskColor = Colors.orange;
            }

            tempAlerts.add({
              'type': 'Tugas',
              'title': 'Deadline: ${t.title}',
              'details': '${t.courseName} - $timeLabel',
              'time': DateFormat('HH:mm').format(t.deadline),
              'date': t.deadline, // Untuk sorting
              'color': taskColor,
              'icon': taskIcon,
            });
          }
        }
      }

      // 2. CEK JADWAL KULIAH HARI INI (Reminder 1 Jam Sebelum)
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

          // Hanya tampilkan jika kelas dimulai/sedang berlangsung (sampai 30 menit setelah mulai)
          if (diffInMinutes > -30) {
            String timeLabel;
            Color classColor = const Color(0xFF2ACDAB);

            if (diffInMinutes < 0) {
              timeLabel = "Sedang Berlangsung";
            } else if (diffInMinutes <= 60) {
              timeLabel = "$diffInMinutes menit lagi";
            } else {
              // Jika lebih dari 60 menit, tampilkan dalam jam
              int hours = (diffInMinutes / 60).floor();
              timeLabel = "$hours jam lagi";
            }

            tempAlerts.add({
              'type': 'Kelas',
              'title': 'Kelas: ${s.name}',
              'details': 'Ruang ${s.room} • $timeLabel',
              'time': s.startTime.format(context),
              'date': classTime,
              'color': classColor,
              'icon': Icons.class_outlined,
            });
          }
        }
      }

      // Sort berdasarkan waktu (paling dekat/segera paling atas)
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
      // Lebih baik menggunakan debugPrint daripada print di Flutter
      debugPrint("Error loading notifications: $e");
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
          // Icon Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (notif['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            // Pastikan 'icon' bertipe IconData
            child: Icon(
              notif['icon'] as IconData,
              color: notif['color'] as Color,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type & Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notif['type'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: notif['color'] as Color,
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
                // Title
                Text(
                  notif['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E2749),
                  ),
                ),
                const SizedBox(height: 3),
                // Details
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
