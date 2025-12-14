import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/exam_service.dart';

class AddExamScreen extends StatefulWidget {
  const AddExamScreen({super.key});

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  final _examService = ExamService();
  final _formKey = GlobalKey<FormState>();

  final _detailsController = TextEditingController();
  final _roomController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = true;
  List<Map<String, dynamic>> _courses = [];
  String? _selectedCourseId;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final data = await _examService.getCoursesForDropdown();
    if (mounted) {
      setState(() {
        _courses = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          _startTime = picked;
        else
          _endTime = picked;
      });
    }
  }

  Future<void> _saveExam() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih mata kuliah')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _examService.addExam(
        courseId: _selectedCourseId!,
        date: _selectedDate,
        startTime: _startTime,
        endTime: _endTime,
        room: _roomController.text.isEmpty
            ? "Belum ditentukan"
            : _roomController.text,
        details: _detailsController.text,
        notes: _notesController.text,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Jadwal Ujian'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 1. DROPDOWN MATKUL
                    DropdownButtonFormField<String>(
                      value: _selectedCourseId,
                      decoration: const InputDecoration(
                        labelText: 'Mata Kuliah',
                        border: OutlineInputBorder(),
                      ),
                      items: _courses
                          .map(
                            (e) => DropdownMenuItem(
                              value: e['id'].toString(),
                              child: Text(e['name']),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCourseId = v),
                    ),
                    const SizedBox(height: 16),

                    // 2. TANGGAL
                    ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      title: Text(
                        'Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)}',
                      ),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 16),

                    // 3. WAKTU (START - END)
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            title: Text(_startTime.format(context)),
                            trailing: const Icon(Icons.access_time),
                            onTap: () => _pickTime(true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('-'),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            title: Text(_endTime.format(context)),
                            trailing: const Icon(Icons.access_time),
                            onTap: () => _pickTime(false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 4. JENIS UJIAN (Details)
                    TextFormField(
                      controller: _detailsController,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Ujian (UTS / UAS)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 5. RUANGAN
                    TextFormField(
                      controller: _roomController,
                      decoration: const InputDecoration(
                        labelText: 'Ruangan',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.room),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 6. NOTES
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Penting)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note_alt),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 7. TOMBOL SIMPAN
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: _saveExam,
                        child: const Text(
                          'Simpan Jadwal Ujian',
                          style: TextStyle(
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
