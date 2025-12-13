// lib/screens/tasks/add_task_screen.dart

import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/task_item.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _nameController = TextEditingController();
  final _detailsController = TextEditingController();
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  String? _selectedCourse;
  Color _selectedColor = const Color(0xFF2ACDAB); // Warna default

  final List<String> _courseOptions = ['IPSI', 'Pemrograman Mobile', 'UI/UX', 'Lainnya'];
  final List<Color> _colorOptions = const [
    Color(0xFF2ACDAB), // Hijau-Biru default
    Color(0xFF1E2749), 
    Color(0xFF3B5998), 
    Color(0xFF4DB6AC), 
    Color(0xFF81C784), 
    Color(0xFFEF5350), 
    Color(0xFFFFB300), 
    Color(0xFF9C27B0), 
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? const TimeOfDay(hour: 23, minute: 59),
    );
    if (picked != null) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  void _saveTask() {
    // FIX: Tambahkan pengecekan null untuk _dueTime agar TaskItem dapat dibuat
    if (_nameController.text.isEmpty || _dueDate == null || _selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tugas, tanggal jatuh tempo, dan mata kuliah harus diisi.')),
      );
      return;
    }

    final newTask = TaskItem(
      name: _nameController.text,
      dueDate: _dueDate!,
      dueTime: _dueTime, // dueTime sudah nullable dan aman
      course: _selectedCourse!,
      details: _detailsController.text,
      color: _selectedColor,
      status: TaskStatus.to_do,
    );

    // Tambahkan ke data global
    AppData.addTask(newTask);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tugas berhasil ditambahkan!')),
    );
    Navigator.pop(context); // Kembali ke layar sebelumnya
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tugas', style: TextStyle(color: Colors.black)),
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
          children: [
            // Input Nama Tugas
            TextField(
              controller: _nameController,
              decoration: _inputDecoration('Name'),
            ),
            const SizedBox(height: 20),
            // Input Tanggal & Waktu Jatuh Tempo
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.flag, color: Color(0xFF2ACDAB)),
                          const SizedBox(width: 10),
                          Text(
                            _dueDate == null ? 'Due Date' : _dueDate!.toLocal().toString().split(' ')[0],
                            style: TextStyle(
                              color: _dueDate == null ? Colors.grey : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Color(0xFF2ACDAB)),
                          const SizedBox(width: 10),
                          Text(
                            _dueTime == null ? 'End Time' : _dueTime!.format(context),
                            style: TextStyle(
                              color: _dueTime == null ? Colors.grey : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Dropdown Mata Kuliah
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Mata Kuliah',
                  contentPadding: EdgeInsets.zero,
                ),
                value: _selectedCourse,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2ACDAB)),
                items: _courseOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCourse = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            // Input Details
            TextField(
              controller: _detailsController,
              maxLines: 5,
              decoration: _inputDecoration('Details').copyWith(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
            ),
            const SizedBox(height: 30),
            // Pemilih Warna
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _colorOptions.map((color) => _buildColorOption(color)).toList(),
            ),
            const SizedBox(height: 50),
            // Tombol Selesai
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ACDAB),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2ACDAB), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }

  Widget _buildColorOption(Color color) {
    bool isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
        child: isSelected
            ? const Center(
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
              )
            : null,
      ),
    );
  }
}