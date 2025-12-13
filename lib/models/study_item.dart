// lib/models/study_item.dart

import 'package:flutter/material.dart';

class StudyItem {
  final String name;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Color color;
  final String lecturerName;
  final String room;
  final String? details; 
  final DateTime? examDate; // Ini yang kita gunakan

  StudyItem({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.lecturerName,
    required this.room,
    this.details,
    this.examDate,
  });
}