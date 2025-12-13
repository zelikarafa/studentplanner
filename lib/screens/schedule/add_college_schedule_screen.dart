// add_college_schedule_screen.dart (TIDAK PERLU DIUBAH, SUDAH BENAR)

import 'package:flutter/material.dart';
import '../../main.dart'; 
import '../../models/study_item.dart'; 

class AddCollegeScheduleScreen extends StatefulWidget {
  const AddCollegeScheduleScreen({super.key});

  @override
  State<AddCollegeScheduleScreen> createState() => _AddCollegeScheduleScreenState();
}

class _AddCollegeScheduleScreenState extends State<AddCollegeScheduleScreen> {
  final _nameController = TextEditingController();
  final _lecturerController = TextEditingController(); 
  final _roomController = TextEditingController(); 
  final _detailsController = TextEditingController(); 
  
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  Color _selectedColor = const Color(0xFF2ACDAB); 

  final List<Color> _colorOptions = const [
    Color(0xFF2ACDAB), 
    Color(0xFF1E2749), 
    Color(0xFF3B5998), 
    Color(0xFF4DB6AC), 
    Color(0xFF81C784), 
    Color(0xFFEF5350), 
    Color(0xFFFFB300), 
    Color(0xFF9C27B0), 
  ];

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initialTime = isStart ? (_startTime ?? TimeOfDay.now()) : (_endTime ?? TimeOfDay.now());
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
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

  void _saveSchedule() {
    if (_nameController.text.isEmpty || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama mata kuliah, waktu mulai, dan waktu selesai harus diisi.')),
      );
      return;
    }

    final newSchedule = StudyItem(
      name: _nameController.text,
      startTime: _startTime!,
      endTime: _endTime!,
      details: _detailsController.text,
      color: _selectedColor,
      lecturerName: _lecturerController.text.isEmpty ? 'TBD' : _lecturerController.text,
      room: _roomController.text.isEmpty ? 'TBD' : _roomController.text,
    );

    // Tambahkan ke data global
    AppData.addCollegeSchedule(newSchedule);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Jadwal Kuliah berhasil ditambahkan!')),
    );
    Navigator.pop(context); // Kembali ke layar sebelumnya
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Mata Kuliah', style: TextStyle(color: Colors.black)),
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
            // Input Nama Mata Kuliah
            TextField(
              controller: _nameController,
              decoration: _inputDecoration('Nama Mata Kuliah'),
            ),
            const SizedBox(height: 20),
            // Input Nama Dosen
            TextField(
              controller: _lecturerController,
              decoration: _inputDecoration('Nama Dosen (Opsional)'),
            ),
            const SizedBox(height: 20),
            // Input Ruangan
            TextField(
              controller: _roomController,
              decoration: _inputDecoration('Ruangan/Lokasi (Opsional)'),
            ),
            const SizedBox(height: 20),
            // Input Waktu Mulai & Selesai
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context, true),
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
                            _startTime == null ? 'Start Time' : _startTime!.format(context),
                            style: TextStyle(
                              color: _startTime == null ? Colors.grey : Colors.black,
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
                    onTap: () => _selectTime(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.play_arrow, color: Color(0xFF2ACDAB)),
                          const SizedBox(width: 10),
                          Text(
                            _endTime == null ? 'End Time' : _endTime!.format(context),
                            style: TextStyle(
                              color: _endTime == null ? Colors.grey : Colors.black,
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
            // Input Details
            TextField(
              controller: _detailsController,
              maxLines: 5,
              decoration: _inputDecoration('Details (Opsional)').copyWith(
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
                onPressed: _saveSchedule,
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