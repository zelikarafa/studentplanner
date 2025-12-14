import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// 🛑 1. PINDAHKAN SEMUA IMPORT KE BAGIAN PALING ATAS
// PASTIKAN PATH INI BENAR
import '../../services/schedule_service.dart';
import '../../models/study_item.dart';
import 'add_college_schedule_screen.dart';

// 🛑 2. PINDAHKAN EXTENSION KE BAWAH SEMUA IMPORT
// --- Wajib Ada: EXTENSION UNTUK TimeOfDay ---
extension TimeOfDayExtension on TimeOfDay {
  String format(BuildContext context) {
    final now = DateTime.now();
    // Gunakan format 24 jam (HH:mm) agar lebih umum di Indonesia
    final dt = DateTime(now.year, now.month, now.day, hour, minute);
    return DateFormat('HH:mm').format(dt);
  }
}
// --- Akhir Extension ---

class ClassScheduleListScreen extends StatefulWidget {
  const ClassScheduleListScreen({super.key});
  // ... (StatefulWidget logic sama)
  @override
  State<ClassScheduleListScreen> createState() =>
      _ClassScheduleListScreenState();
}

class _ClassScheduleListScreenState extends State<ClassScheduleListScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  List<StudyItem> _classSchedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    setState(() => _isLoading = true);
    try {
      final data = await _scheduleService.getSchedules();

      data.sort((a, b) {
        int dayComparison = a.dayOfWeek.compareTo(b.dayOfWeek);
        if (dayComparison != 0) return dayComparison;

        int timeA = a.startTime.hour * 60 + a.startTime.minute;
        int timeB = b.startTime.hour * 60 + b.startTime.minute;
        return timeA.compareTo(timeB);
      });

      if (mounted) {
        setState(() {
          _classSchedules = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching class schedules: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getDayName(int dayOfWeek) {
    const dayNames = {
      1: 'Senin',
      2: 'Selasa',
      3: 'Rabu',
      4: 'Kamis',
      5: 'Jumat',
      6: 'Sabtu',
      7: 'Minggu',
    };
    return dayNames[dayOfWeek] ?? 'Hari Tidak Dikenal';
  }

  void _navigateToEdit(StudyItem? item) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCollegeScheduleScreen(initialData: item),
      ),
    );
    if (result == true) {
      _fetchSchedules();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Jadwal Kelas'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E2749),
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2ACDAB)),
            )
          : _classSchedules.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _classSchedules.length,
              itemBuilder: (context, index) {
                final item = _classSchedules[index];
                return _buildScheduleCard(item);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2ACDAB),
        onPressed: () => _navigateToEdit(null),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildScheduleCard(StudyItem item) {
    final startTimeStr = item.startTime.format(context);
    final endTimeStr = item.endTime.format(context);
    final dayName = _getDayName(item.dayOfWeek);

    return InkWell(
      onTap: () => _navigateToEdit(item),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: const Color(0xFF2ACDAB).withAlpha((255 * 0.1).round()),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 5,
                height: 65,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ACDAB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E2749),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dayName, $startTimeStr - $endTimeStr',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    if (item.room != null && item.room!.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ruangan: ${item.room}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                onPressed: () => _navigateToEdit(item),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            "Belum ada jadwal kuliah mingguan.",
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            "Tekan tombol '+' untuk menambah jadwal.",
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
