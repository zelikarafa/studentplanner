// lib/screens/tasks/tasks_screen.dart

import 'package:flutter/material.dart';
import '../../main.dart'; 
import '../../models/task_item.dart';
import 'add_task_screen.dart';

// Extension untuk mendapatkan nama hari (Tidak ada perubahan)
extension DateTimeExtension on DateTime {
  String get dayName {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
}

class TasksScreen extends StatefulWidget {
  final TaskStatus initialStatus;
  const TasksScreen({super.key, this.initialStatus = TaskStatus.to_do});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskStatus _currentStatus = TaskStatus.to_do;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus;
  }

  // Fungsi untuk mengecek dan memperbarui status missed saat ini
  void _checkMissedTasks() {
    final now = DateTime.now();
    for (var task in AppData.tasks) {
      if (task.status == TaskStatus.to_do) {
        // FIX: Gunakan TimeOfDay(hour: 23, minute: 59) jika dueTime null
        final dueTimeSafe = task.dueTime ?? const TimeOfDay(hour: 23, minute: 59);
        
        // Gabungkan tanggal dan waktu menjadi satu DateTime untuk perbandingan
        final fullDueDateTime = DateTime(
          task.dueDate.year,
          task.dueDate.month,
          task.dueDate.day,
          dueTimeSafe.hour, // Akses kini aman
          dueTimeSafe.minute, // Akses kini aman
        );
        if (fullDueDateTime.isBefore(now)) {
          task.status = TaskStatus.missed;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Memanggil _checkMissedTasks untuk memperbarui status missed
    _checkMissedTasks();
    
    List<TaskItem> filteredTasks = AppData.tasks.where((task) => task.status == _currentStatus).toList();
    // fullDueDate diambil dari getter di task_item.dart
    filteredTasks.sort((a, b) => a.fullDueDate.compareTo(b.fullDueDate)); 

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentStatus == TaskStatus.to_do ? 'Tugas' : 'Tasks', style: const TextStyle(color: Colors.black)),
        centerTitle: false,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: _buildStatusSelector(),
          ),
          Expanded(
            child: filteredTasks.isEmpty && _currentStatus == TaskStatus.to_do
                ? _buildEmptyState()
                : _buildTaskList(filteredTasks),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatusButton('To Do', TaskStatus.to_do),
        _buildStatusButton('Missed', TaskStatus.missed),
        _buildStatusButton('Completed', TaskStatus.completed),
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTaskScreen()),
            );
            setState(() {}); 
          },
          child: const Row(
            children: [
              Icon(Icons.add, color: Color(0xFF2ACDAB)),
              Text('New Task', style: TextStyle(color: Color(0xFF2ACDAB), fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStatusButton(String title, TaskStatus status) {
    bool isSelected = _currentStatus == status;
    return InkWell(
      onTap: () {
        setState(() {
          _currentStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2ACDAB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.red.shade100, width: 2),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red, size: 80),
            SizedBox(height: 10),
            Text(
              'TIDAK ADA TUGAS YANG HARUS DILAKUKAN',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<TaskItem> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(TaskItem task) {
    String dueText;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (task.dueDate.day == today.day && task.dueDate.month == today.month && task.dueDate.year == today.year) {
      dueText = 'Due: Today, ${task.dueDate.dayName} ${task.dueDate.day}';
    } else if (task.dueDate.day == yesterday.day && task.dueDate.month == yesterday.month && task.dueDate.year == yesterday.year) {
      dueText = 'Due: Yesterday, ${task.dueDate.dayName} ${task.dueDate.day}';
    } 
    else {
      dueText = 'Due: ${task.dueDate.dayName}, ${task.dueDate.day}/${task.dueDate.month}';
    }

    // FIX Null safety: Gunakan null-aware operator '?' dan fallback text 'No Time Specified'
    String timeRange = task.dueTime?.format(context) ?? 'No Time Specified'; 

    return Dismissible(
      key: Key(task.name),
      direction: task.status == TaskStatus.to_do ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: const Color(0xFF2ACDAB),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          setState(() {
            AppData.tasks.remove(task); 
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${task.name} dihapus')));
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.status != TaskStatus.completed)
              Text(
                dueText, 
                style: TextStyle(
                  color: task.status == TaskStatus.missed ? Colors.red : Colors.grey.shade600, 
                  fontWeight: FontWeight.bold
                )
              ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: task.status == TaskStatus.completed ? Colors.lightGreen : 
                          task.status == TaskStatus.missed ? Colors.red : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    // FIX withOpacity: Mengganti dengan Color.fromRGBO
                    color: const Color.fromRGBO(158, 158, 158, 0.1), 
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 60,
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      color: task.color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due Time: $timeRange', 
                          style: TextStyle(
                            color: task.status == TaskStatus.missed ? Colors.red : Colors.grey.shade600, 
                            fontSize: 12
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          task.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: task.status == TaskStatus.missed ? Colors.red : Colors.black,
                          ),
                        ),
                        Text(
                          task.details,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (task.status == TaskStatus.to_do)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'complete') {
                          setState(() {
                            task.status = TaskStatus.completed;
                          });
                        } else if (value == 'delete') {
                            setState(() {
                            AppData.tasks.remove(task);
                          });
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'complete',
                          child: Text('Tandai Selesai'),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Hapus'),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                    )
                  else if (task.status == TaskStatus.completed)
                    // FIX: Hapus 'const'
                    Icon(Icons.check_circle, color: Colors.lightGreen)
                  else if (task.status == TaskStatus.missed)
                    // FIX: Hapus 'const'
                    Icon(Icons.error, color: Colors.red), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}