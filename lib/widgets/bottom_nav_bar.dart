import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Definisi warna utama yang sering digunakan di desain
    const Color primaryColor = Color(0xFF2ACDAB);
    const Color unselectedColor = Color(0xFFB0B0C0); 

    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Kalender',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_open_outlined),
          activeIcon: Icon(Icons.folder),
          label: 'Tugas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none_outlined),
          activeIcon: Icon(Icons.notifications),
          label: 'Pemberitahuan',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: primaryColor,
      unselectedItemColor: unselectedColor,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed, // Penting agar tidak menghilang
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}