import 'package:flutter/material.dart';

import 'tabs/fo_booking_tab.dart';
import 'tabs/fo_check_in_tab.dart';
import 'tabs/fo_check_out_tab.dart';
import 'tabs/fo_dashboard_tab.dart';

/// Dashboard Front Office (Staf Depan) Hotel
/// Terbagi menjadi 4 Modul / Tab:
/// 1. FoDashboardTab: Ringkasan Operasional, Scanner E-Tiket, Aksi Cepat
/// 2. FoBookingTab: Verifikasi Reservasi Tamu, Filter, Slip Transfer
/// 3. FoCheckInTab: Proses Check-in Tamu, Pencarian, Serah Kunci RFID
/// 4. FoCheckOutTab: Proses Check-out Tamu, Waktu Keluar, Checklist Deposit & Handover
class FoDashboardScreen extends StatefulWidget {
  const FoDashboardScreen({super.key});

  @override
  State<FoDashboardScreen> createState() => _FoDashboardScreenState();
}

class _FoDashboardScreenState extends State<FoDashboardScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: Column(
          children: [
            // Header Top Bar
            _buildTopAppBar(),

            // Body Sesuai Tab yang Aktif
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: [
                  FoDashboardTab(
                    onNavigateTab: (index) {
                      setState(() => _currentTabIndex = index);
                    },
                  ),
                  const FoBookingTab(),
                  const FoCheckInTab(),
                  const FoCheckOutTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ===========================================================================
  // TOP APP BAR
  // ===========================================================================
  Widget _buildTopAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Badge Staf Ops
          Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.confirmation_number_outlined,
                  color: Color(0xFF00B4D8),
                  size: 26,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F4FB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Staf Ops',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),

          // Role & Shift info + Profile Avatar
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'Front Desk Ops',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Shift Pagi (07:00–15:00)',
                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF00C2FF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'MF',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BOTTOM NAVIGATION BAR
  // ===========================================================================
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00758F),
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle:
            const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
        unselectedLabelStyle:
            const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number_rounded),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room_outlined),
            activeIcon: Icon(Icons.meeting_room_rounded),
            label: 'Check In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.door_sliding_outlined),
            activeIcon: Icon(Icons.door_sliding_rounded),
            label: 'Check Out',
          ),
        ],
      ),
    );
  }
}
