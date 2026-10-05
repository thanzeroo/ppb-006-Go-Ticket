import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/storage_helper.dart';
import '../auth/super_admin_login_screen.dart';
import '../dashboard/super_admin_dashboard_screen.dart';

/// Halaman Loading / Splash Screen untuk Super Admin Go Ticket.
/// Menampilkan latar belakang gelap dengan logo Go Ticket di tengah,
/// lalu secara otomatis berpindah ke Super Admin Dashboard atau Login.
class SuperAdminLoadingScreen extends StatefulWidget {
  const SuperAdminLoadingScreen({super.key});

  @override
  State<SuperAdminLoadingScreen> createState() =>
      _SuperAdminLoadingScreenState();
}

class _SuperAdminLoadingScreenState extends State<SuperAdminLoadingScreen> {
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

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isLoggedIn
              ? const SuperAdminDashboardScreen()
              : const SuperAdminLoginScreen(),
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
            'assets/logo.png',
            width: 220,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
