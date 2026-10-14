import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/staff_login_screen.dart';

class HotelSplashScreen extends StatefulWidget {
  const HotelSplashScreen({super.key});

  @override
  State<HotelSplashScreen> createState() => _HotelSplashScreenState();
}

class _HotelSplashScreenState extends State<HotelSplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StaffLoginScreen()),
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

    return const Scaffold(
      backgroundColor: Color(0xFF0D3B55),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hotel, size: 64, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'GoTicket',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Pihak Hotel',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
