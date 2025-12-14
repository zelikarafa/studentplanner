import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import ini hanya contoh, pastikan Anda menggunakan nama file/route Login Anda
// Jika Anda menggunakan routing bernama, pastikan '/' mengarah ke Login
// import 'login_screen.dart'; // Contoh jika Anda menggunakan navigasi MaterialPageRoute

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;

  String _name = 'Loading...';
  String _email = '...';
  bool _isLoading = true; // State baru untuk loading

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      if (mounted) {
        // Jika user null saat pertama kali masuk, langsung arahkan ke login
        _safeNavigateToLogin(context);
        return;
      }
    }

    // Set email di awal
    if (mounted) {
      setState(() {
        _email = user?.email ?? '-';
        _isLoading = true;
      });
    }

    try {
      final data = await _supabase
          .from('profiles')
          .select('full_name') // Hanya select kolom yang dibutuhkan
          .eq('id', user!.id)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _name = data['full_name'] ?? 'Mahasiswa';
          _isLoading = false;
        });
      } else if (mounted) {
        // Jika data profile tidak ditemukan, gunakan default
        setState(() {
          _name = 'Mahasiswa';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
      if (mounted) {
        setState(() {
          _name = 'Error Load Data';
          _isLoading = false;
        });
      }
    }
  }

  void _safeNavigateToLogin(BuildContext context) {
    // Fungsi untuk memastikan navigasi dilakukan dengan aman
    // Asumsi: '/' adalah route ke halaman Login/AuthWrapper
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Future<void> _signOut() async {
    // Tampilkan loading/indikator bahwa proses logout sedang berjalan
    if (mounted) setState(() => _isLoading = true);

    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint("Sign Out Error: $e");
    } finally {
      if (mounted) {
        // Kembali ke Login dan hapus semua history route
        _safeNavigateToLogin(context);
      }
    }
  }

  // Helper untuk mendapatkan inisial nama
  String _getInitial(String name) {
    if (name.isEmpty || name == 'Loading...') return '?';
    return name
        .trim()
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Color(0xFF1E2749))),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2749)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading && _name == 'Loading...'
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2ACDAB)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // FOTO PROFIL (Menggunakan Inisial Nama)
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF2ACDAB),
                    child: Text(
                      _getInitial(_name),
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // NAMA & EMAIL
                  Text(
                    _name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2749),
                    ),
                  ),
                  Text(
                    _email,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // MENU DUMMY
                  _buildProfileMenu(
                    context,
                    Icons.person_outline,
                    'Akun Saya',
                    () {
                      // TODO: Navigasi ke Edit Profil
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Halaman Akun Saya (TODO)'),
                        ),
                      );
                    },
                  ),
                  _buildProfileMenu(context, Icons.lock_outline, 'Privasi', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Halaman Privasi (TODO)')),
                    );
                  }),
                  _buildProfileMenu(
                    context,
                    Icons.settings_outlined,
                    'Pengaturan',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Halaman Pengaturan (TODO)'),
                        ),
                      );
                    },
                  ),
                  _buildProfileMenu(context, Icons.help_outline, 'Bantuan', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Halaman Bantuan (TODO)')),
                    );
                  }),

                  const SizedBox(height: 40),

                  // TOMBOL LOGOUT
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : _signOut, // Disable saat loading
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: Text(
                        _isLoading ? 'Sedang Logout...' : 'Logout',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget _buildProfileMenu tidak berubah, tetap rapi
  Widget _buildProfileMenu(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    // ... (kode _buildProfileMenu yang sama)
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ACDAB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF2ACDAB)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E2749),
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
