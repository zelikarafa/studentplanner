import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/task_service.dart'; // Pastikan path ini benar

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _taskService = TaskService(); // Pakai Service
  final _formKey = GlobalKey<FormState>();

  final _titleController =
      TextEditingController(); // Ganti name jadi title sesuai DB
  final _detailsController = TextEditingController();

  bool _isLoading = true;
  List<Map<String, dynamic>> _courseList = []; // Data Dropdown
  String? _selectedCourseId;

  // Default Deadline: Besok jam 23:59
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 23, minute: 59);

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  // Ambil list matkul dari Supabase
  Future<void> _loadCourses() async {
    try {
      final courses = await _taskService.getCoursesForDropdown();
      if (mounted) {
        setState(() {
          _courseList = courses;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error silent
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Gabungkan Date & Time Picker
  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time == null) return;

    setState(() {
      _selectedDate = date;
      _selectedTime = time;
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap pilih Mata Kuliah')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Gabungkan Date & Time jadi satu DateTime untuk Database
      final finalDeadline = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await _taskService.addTask(
        courseId: _selectedCourseId!,
        title: _titleController.text,
        details: _detailsController.text,
        deadline: finalDeadline,
      );

      if (mounted) {
        Navigator.pop(context, true); // Return true agar halaman depan refresh
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Tugas Baru')),
      body: _isLoading && _courseList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= JUDUL =================
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Tugas',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 15),

                    // ================= COURSE =================
                    DropdownButtonFormField<String>(
                      value: _selectedCourseId,
                      decoration: const InputDecoration(
                        labelText: 'Mata Kuliah',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book),
                      ),
                      hint: const Text('Pilih Matkul'),
                      items: _courseList.map((course) {
                        return DropdownMenuItem<String>(
                          value: course['id'].toString(), // ID Matkul UUID
                          child: Text(course['name']), // Nama Matkul
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedCourseId = v),
                    ),
                    if (_courseList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          'Belum ada mata kuliah. Tambahkan di menu Jadwal/Database.',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 15),

                    // ================= DEADLINE =================
                    InkWell(
                      onTap: _pickDateTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Deadline',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd MMM yyyy').format(_selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              _selectedTime.format(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // ================= DETAILS =================
                    TextFormField(
                      controller: _detailsController,
                      decoration: const InputDecoration(
                        labelText: 'Detail / Catatan',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 30),

                    // ================= SAVE BUTTON =================
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2ACDAB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _isLoading ? null : _saveTask,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'SIMPAN TUGAS',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
