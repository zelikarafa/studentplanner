import 'package:flutter/material.dart';
import '../../services/schedule_service.dart';

class AddCollegeScheduleScreen extends StatefulWidget {
  const AddCollegeScheduleScreen({super.key});

  @override
  State<AddCollegeScheduleScreen> createState() =>
      _AddCollegeScheduleScreenState();
}

class _AddCollegeScheduleScreenState extends State<AddCollegeScheduleScreen> {
  final _scheduleService = ScheduleService();

  // Form State
  String? _selectedCourseId;
  int _selectedDay = 1; // 1 = Senin
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  final _roomController = TextEditingController();
  final _detailsController = TextEditingController();

  // Data Logic
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
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
      await _scheduleService.addSchedule(
        courseId: _selectedCourseId!,
        dayOfWeek: _selectedDay,
        startTime: _startTime,
        endTime: _endTime,
        room: _roomController.text,
        details: _detailsController.text,
      );

      if (mounted) {
        // PENTING: Kirim 'true' agar halaman depan me-refresh data
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal berhasil disimpan!')),
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
        title: const Text(
          "Tambah Jadwal",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. DROPDOWN MATKUL
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
                      return DropdownMenuItem<String>(
                        value: course['id'],
                        child: Text(course['name']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCourseId = val;
                        // Optional: Auto-fill room kalau user pilih matkul
                        // final selected = _courses.firstWhere((c) => c['id'] == val);
                        // if (selected['default_room'] != null) {
                        //   _roomController.text = selected['default_room'];
                        // }
                      });
                    },
                  ),

                  // Link ke Master Data jika list kosong
                  if (_courses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Belum ada Mata Kuliah. Buat Master Data dulu.",
                        style: TextStyle(color: Colors.red[400], fontSize: 12),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // 2. HARI
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

                  // 3. JAM MULAI & SELESAI
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePicker("Jam Mulai", _startTime, (val) {
                          setState(() => _startTime = val);
                        }),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildTimePicker("Jam Selesai", _endTime, (val) {
                          setState(() => _endTime = val);
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 4. RUANGAN (Optional)
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

                  // 5. CATATAN
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

                  // TOMBOL SIMPAN
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
                      child: const Text(
                        "Simpan Jadwal",
                        style: TextStyle(color: Colors.white, fontSize: 16),
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
}
