import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_item.dart';
import '../../services/task_service.dart';
import 'add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskService _taskService = TaskService();
  int _activeTabIndex = 0;
  List<TaskItem> _allTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final data = await _taskService.getTasks();
      if (mounted) {
        setState(() {
          _allTasks = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // FILTER LOGIC
    // Kita pakai getter isToDo, isMissed, isDone dari Model yang baru
    List<TaskItem> displayedTasks = [];
    if (_activeTabIndex == 0) {
      displayedTasks = _allTasks.where((t) => t.isToDo).toList();
    } else if (_activeTabIndex == 1) {
      displayedTasks = _allTasks.where((t) => t.isMissed).toList();
    } else {
      // Tab Selesai: Pakai isDone (status == 'completed')
      displayedTasks = _allTasks.where((t) => t.isDone).toList();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Daftar Tugas',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,

        // --- 1. TOMBOL BACK (PERBAIKAN) ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        // ----------------------------------
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabButton('To Do', 0),
                _buildTabButton('Missed', 1),
                _buildTabButton('Selesai', 2),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayedTasks.isEmpty
                ? _buildEmptyState()
                : _buildTaskList(displayedTasks),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
          // Refresh kalau ada data baru
          if (result == true) _loadTasks();
        },
        backgroundColor: const Color(0xFF2ACDAB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _activeTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _activeTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2ACDAB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Tidak ada tugas.',
        style: TextStyle(color: Colors.grey[500], fontSize: 16),
      ),
    );
  }

  Widget _buildTaskList(List<TaskItem> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (_, index) => _buildTaskCard(tasks[index]),
    );
  }

  Widget _buildTaskCard(TaskItem task) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: task.priorityColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        // --- 2. LOGIKA CHECKBOX (PERBAIKAN) ---
        leading: Checkbox(
          activeColor: const Color(0xFF2ACDAB),
          // Gunakan .isDone (bukan isCompleted lagi)
          value: task.isDone,
          onChanged: (val) async {
            // val adalah nilai baru (true/false) yang dikirim ke service
            if (val != null) {
              await _taskService.toggleComplete(task.id, val);
              _loadTasks(); // Refresh UI setelah update
            }
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            // Coret tulisan jika isDone
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.courseName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              'Deadline: ${DateFormat('dd MMM HH:mm').format(task.deadline)}',
              style: TextStyle(
                color: task.priorityColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () async {
            await _taskService.deleteTask(task.id);
            _loadTasks();
          },
        ),
      ),
    );
  }
}
