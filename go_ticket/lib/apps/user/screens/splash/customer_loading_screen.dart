import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/storage_helper.dart';
import '../auth/customer_login_screen.dart';
import '../dashboard/customer_dashboard_screen.dart';

/// Halaman Loading / Splash Screen untuk User (Customer).
/// Menampilkan latar belakang gelap dengan logo Go Ticket di tengah,
/// lalu secara otomatis berpindah ke halaman Login atau Dashboard.
class CustomerLoadingScreen extends StatefulWidget {
  const CustomerLoadingScreen({super.key});

  @override
  State<CustomerLoadingScreen> createState() => _CustomerLoadingScreenState();
}

class _CustomerLoadingScreenState extends State<CustomerLoadingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Menunggu selama 2 detik lalu mengecek sesi login user
  void _startTimer() {
    _timer = Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;

      // Cek apakah user sudah login
      final isLoggedIn = await StorageHelper.isLoggedIn();

      if (!mounted) return;

      // Navigasi ke halaman tujuan
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isLoggedIn
              ? const CustomerDashboardScreen()
              : const CustomerLoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mengatur warna ikon status bar (jam & baterai) agar terlihat putih
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      // Warna background gelap kebiruan sesuai desain mockup
      backgroundColor: const Color(0xFF13222B),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Image.asset(
            'assets/Go_Ticket_Short_logo 1 (1).png',
            width: 220,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/logo.png',
                width: 220,
                fit: BoxFit.contain,
              );
            },
          ),
        ),
      ),
    );
  }
}
