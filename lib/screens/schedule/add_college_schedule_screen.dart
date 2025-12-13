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
  final _formKey = GlobalKey<FormState>();

  // State untuk Dropdown & Input
  bool _isLoading = true;
  List<Map<String, dynamic>> _courseList = []; // List Matkul untuk Dropdown
  String? _selectedCourseId; // ID Matkul yang dipilih
  int _selectedDay = 1; // Default Senin
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  // Mapping Angka Hari ke Nama Hari
  final Map<int, String> _days = {
    1: 'Senin',
    2: 'Selasa',
    3: 'Rabu',
    4: 'Kamis',
    5: 'Jumat',
    6: 'Sabtu',
    7: 'Minggu',
  };

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  // Ambil data mata kuliah dari Supabase untuk Dropdown
  Future<void> _loadCourses() async {
    final courses = await _scheduleService.getCoursesForDropdown();
    setState(() {
      _courseList = courses;
      _isLoading = false;
    });
  }

  // Fungsi Simpan Jadwal
  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mohon pilih Mata Kuliah')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _scheduleService.addSchedule(
        courseId: _selectedCourseId!,
        dayOfWeek: _selectedDay,
        startTime: _startTime,
        endTime: _endTime,
        room: _roomController.text.isEmpty ? null : _roomController.text,
        details: _detailsController.text.isEmpty
            ? null
            : _detailsController.text,
      );

      if (mounted) {
        Navigator.pop(context, true); // Kembali ke halaman sebelumnya & refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper untuk Memilih Jam
  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Jadwal Kuliah')),
      body: _isLoading && _courseList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. DROPDOWN MATA KULIAH
                    const Text(
                      'Mata Kuliah',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCourseId,
                      hint: const Text('Pilih Mata Kuliah'),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: _courseList.map((course) {
                        return DropdownMenuItem<String>(
                          value: course['id'].toString(), // ID Matkul (UUID)
                          child: Text(course['name']), // Nama Matkul
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCourseId = value);
                      },
                      validator: (value) =>
                          value == null ? 'Wajib dipilih' : null,
                    ),

                    // Info jika Matkul Kosong
                    if (_courseList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Belum ada mata kuliah. Silakan buat master mata kuliah terlebih dahulu (bisa diimplementasikan terpisah).',
                          style: TextStyle(
                            color: Colors.red[300],
                            fontSize: 12,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // 2. DROPDOWN HARI
                    const Text(
                      'Hari',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedDay,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: _days.entries.map((entry) {
                        return DropdownMenuItem<int>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedDay = val!),
                    ),

                    const SizedBox(height: 16),

                    // 3. JAM MULAI & SELESAI
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jam Mulai',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ListTile(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                title: Text(_startTime.format(context)),
                                trailing: const Icon(Icons.access_time),
                                onTap: () => _pickTime(true),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jam Selesai',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ListTile(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                title: Text(_endTime.format(context)),
                                trailing: const Icon(Icons.access_time),
                                onTap: () => _pickTime(false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 4. RUANGAN (Optional Override)
                    const Text(
                      'Ruangan (Opsional)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _roomController,
                      decoration: const InputDecoration(
                        hintText: 'Isi jika beda dari default matkul',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 5. CATATAN
                    const Text(
                      'Catatan Tambahan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _detailsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // TOMBOL SIMPAN
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveSchedule,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Simpan Jadwal'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
