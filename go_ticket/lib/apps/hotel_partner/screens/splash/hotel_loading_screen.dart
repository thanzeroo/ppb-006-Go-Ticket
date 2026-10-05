import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/storage_helper.dart';
import '../auth/staff_login_screen.dart';
import '../../router/role_guard.dart';

/// Halaman Loading / Splash Screen untuk Pihak Hotel.
/// Menampilkan latar belakang gelap dengan logo Go Ticket Hotel di tengah,
/// lalu secara otomatis berpindah ke RoleGuard (jika sudah login) atau StaffLoginScreen.
class HotelLoadingScreen extends StatefulWidget {
  const HotelLoadingScreen({super.key});

  @override
  State<HotelLoadingScreen> createState() => _HotelLoadingScreenState();
}

class _HotelLoadingScreenState extends State<HotelLoadingScreen> {
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

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;

      final isLoggedIn = await StorageHelper.isLoggedIn();
      final userRole = await StorageHelper.getUserRole();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isLoggedIn
              ? RoleGuard(userRole: userRole)
              : const StaffLoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF13222B),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Image.asset(
            'assets/logo_hotel.png',
            width: 220,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/logo.png',
              width: 220,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
