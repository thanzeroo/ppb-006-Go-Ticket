import 'package:flutter/material.dart';

import '../../router/hotel_router.dart';

/// Dashboard Staff Front Office.
class FoDashboardScreen extends StatefulWidget {
  const FoDashboardScreen({super.key});

  @override
  State<FoDashboardScreen> createState() => _FoDashboardScreenState();
}

class _FoDashboardScreenState extends State<FoDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.black),
            tooltip: 'Scan QR Check-in',
            onPressed: () => Navigator.pushNamed(context, HotelRouter.qrScanCheckin),
          ),
        ],
      ),
      body: _buildPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black38,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login_outlined),
            activeIcon: Icon(Icons.login),
            label: 'Check-in',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout_outlined),
            activeIcon: Icon(Icons.logout),
            label: 'Check-out',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Booking',
          ),
        ],
      ),
    );
  }

  static const List<String> _titles = [
    'Front Office',
    'Check-in',
    'Check-out',
    'Booking',
  ];

  Widget _buildPage(int index) {
    return Center(
      child: Text(
        _titles[index],
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }
}
