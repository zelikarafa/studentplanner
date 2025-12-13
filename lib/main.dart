import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// SCREEN IMPORTS
import 'screens/auth/signin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/schedule/college_schedule_screen.dart';
import 'screens/tasks/tasks_screen.dart';
import 'screens/exams/exam_screen.dart'; // Folder exams baru

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INIT FORMAT TANGGAL INDONESIA
  await initializeDateFormatting('id_ID', null);

  // INIT SUPABASE
  await Supabase.initialize(
    url: 'https://bkpxlrqzgsezggwxymbo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJrcHhscnF6Z3Nlemdnd3h5bWJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU2MzQ2MTYsImV4cCI6MjA4MTIxMDYxNn0.sttuZI38DpYraMB9I-Il29h9k_VhUrhMVcSPpFuPC0Q',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Study Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        // Warna utama aplikasi
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2ACDAB),
          primary: const Color(0xFF2ACDAB),
        ),
      ),
      // ROUTING / NAVIGASI
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const SigninScreen(),
        '/home': (context) => const HomeScreen(),
        '/schedule': (context) => const CollegeScheduleScreen(),
        '/exams': (context) => const ExamScreen(),
        '/tasks': (context) => const TasksScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

// =======================================================
// AUTH GATE (AUTO LOGIN)
// =======================================================
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder mendengarkan status login secara realtime
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;

        // Jika ada session (sudah login) -> Ke Home
        if (session != null) {
          return const HomeScreen();
        }

        // Jika belum login -> Ke Sign In
        return const SigninScreen();
      },
    );
  }
}
