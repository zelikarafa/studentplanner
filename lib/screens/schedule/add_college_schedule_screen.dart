import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/study_item.dart';
import '../../services/schedule_service.dart';

// --- Wajib Ada: EXTENSION UNTUK TimeOfDay ---
extension TimeOfDayExtension on TimeOfDay {
  String format(BuildContext context) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, hour, minute);
    return DateFormat('HH:mm').format(dt);
  }
}
// --- Akhir Extension ---

class AddCollegeScheduleScreen extends StatefulWidget {
  final StudyItem? initialData;

  const AddCollegeScheduleScreen({super.key, this.initialData});

  @override
  State<AddCollegeScheduleScreen> createState() =>
      _AddCollegeScheduleScreenState();
}

class _AddCollegeScheduleScreenState extends State<AddCollegeScheduleScreen> {
  final _scheduleService = ScheduleService();

  // State
  String? _selectedCourseId;
  int _selectedDay = 1;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  final _roomController = TextEditingController();
  final _detailsController = TextEditingController();

  // Data Logic
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;
  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();

    // Inisialisasi data untuk Edit
    if (_isEditing) {
      final item = widget.initialData!;
      _selectedCourseId = item.courseId;
      _selectedDay = item.dayOfWeek;
      _startTime = item.startTime;
      _endTime = item.endTime;
      // Gunakan null-aware operator untuk room/details yang mungkin null
      _roomController.text = item.room ?? '';
      _detailsController.text = item.details ?? '';
    }
    _loadCourses();
  }

  @override
  void dispose() {
    _roomController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    final data = await _scheduleService.getCoursesForDropdown();
    setState(() {
      _courses = data;
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih Mata Kuliah dulu!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        // Panggil updateSchedule yang baru ditambahkan
        await _scheduleService.updateSchedule(
          scheduleId:
              widget.initialData!.id, // Menggunakan ID yang sudah pasti ada
          courseId: _selectedCourseId!,
          dayOfWeek: _selectedDay,
          startTime: _startTime,
          endTime: _endTime,
          room: _roomController.text,
          details: _detailsController.text,
        );
      } else {
        // Mode Tambah Baru
        await _scheduleService.addSchedule(
          courseId: _selectedCourseId!,
          dayOfWeek: _selectedDay,
          startTime: _startTime,
          endTime: _endTime,
          room: _roomController.text,
          details: _detailsController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Jadwal berhasil diperbarui!'
                  : 'Jadwal berhasil disimpan!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? "Edit Jadwal" : "Tambah Jadwal",
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2ACDAB)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... (Form input Matkul, Hari, Jam, Ruangan, Catatan sama)
                  const Text(
                    "Mata Kuliah",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCourseId,
                    hint: const Text("Pilih Mata Kuliah"),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                    ),
                    items: _courses.map((course) {
                      // Casting aman untuk Dropdown
                      return DropdownMenuItem<String>(
                        value: course['id'] as String?,
                        child: Text(course['name'] as String? ?? 'N/A'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCourseId = val),
                  ),

                  if (_courses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Belum ada Mata Kuliah. Buat Master Data dulu.",
                        style: TextStyle(color: Colors.red[400], fontSize: 12),
                      ),
                    ),

                  const SizedBox(height: 20),

                  const Text(
                    "Hari",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedDay,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text("Senin")),
                      DropdownMenuItem(value: 2, child: Text("Selasa")),
                      DropdownMenuItem(value: 3, child: Text("Rabu")),
                      DropdownMenuItem(value: 4, child: Text("Kamis")),
                      DropdownMenuItem(value: 5, child: Text("Jumat")),
                      DropdownMenuItem(value: 6, child: Text("Sabtu")),
                      DropdownMenuItem(value: 7, child: Text("Minggu")),
                    ],
                    onChanged: (val) => setState(() => _selectedDay = val!),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePicker(
                          "Jam Mulai",
                          _startTime,
                          (val) => setState(() => _startTime = val),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildTimePicker(
                          "Jam Selesai",
                          _endTime,
                          (val) => setState(() => _endTime = val),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Ruangan (Opsional)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _roomController,
                    decoration: InputDecoration(
                      hintText: "Isi jika beda dari default",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Catatan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _detailsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Catatan tambahan...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ACDAB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _isEditing ? "Perbarui Jadwal" : "Simpan Jadwal",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          // ✅ PERBAIKAN 3: ID di StudyItem adalah int
                          onPressed: () =>
                              _deleteSchedule(widget.initialData!.id),
                          child: const Text(
                            'Hapus Jadwal',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildTimePicker(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onPicked,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: const Color(0xFF2ACDAB),
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) onPicked(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time.format(context)),
                const Icon(Icons.access_time, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ✅ PERBAIKAN 4: Ubah tipe scheduleId menjadi int
  Future<void> _deleteSchedule(int scheduleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _scheduleService.deleteSchedule(scheduleId);
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jadwal berhasil dihapus.')),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
        }
      }
    }
  }
}
