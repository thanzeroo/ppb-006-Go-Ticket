import 'package:flutter/material.dart';

import 'apps/pihak_go_ticket/screens/splash/admin_splash_screen.dart';
import 'apps/pihak_hotel/screens/splash/hotel_splash_screen.dart';
import 'apps/pihak_user/screens/splash/customer_loading_screen.dart';

void main() {
  runApp(const GoTicketApp());
}

class GoTicketApp extends StatelessWidget {
  const GoTicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Go Ticket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00C2FF)),
        useMaterial3: true,
      ),
      home: const PortalSelectionScreen(),
    );
  }
}

/// Layar pemilihan portal — bersih, terpusat di tengah layar, dan minimalis.
class PortalSelectionScreen extends StatelessWidget {
  const PortalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Go Ticket dengan Box & Cyan Glow
                  Center(child: _buildLogoHeader()),
                  const SizedBox(height: 18),

                  // Judul Sederhana & Bersih
                  const Text(
                    'Go Ticket',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pilih portal untuk melanjutkan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 1. Portal User (Tamu)
                  _buildPortalButton(
                    context: context,
                    label: 'User (Tamu)',
                    subtitle: 'Cari & booking hotel',
                    icon: Icons.person_outline_rounded,
                    color: const Color(0xFF00B4D8),
                    destination: const CustomerLoadingScreen(),
                  ),
                  const SizedBox(height: 14),

                  // 2. Portal Pihak Hotel
                  _buildPortalButton(
                    context: context,
                    label: 'Pihak Hotel',
                    subtitle: 'Kelola hotel mitra',
                    icon: Icons.hotel_outlined,
                    color: const Color(0xFF0D3B55),
                    destination: const HotelSplashScreen(),
                  ),
                  const SizedBox(height: 14),

                  // 3. Portal Pihak Go Ticket
                  _buildPortalButton(
                    context: context,
                    label: 'Pihak Go Ticket',
                    subtitle: 'Panel administrasi platform',
                    icon: Icons.admin_panel_settings_outlined,
                    color: const Color(0xFF7C3AED),
                    destination: const AdminSplashScreen(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Logo Header dengan rounded card & glowing cyan shadow
  Widget _buildLogoHeader() {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C7F2).withValues(alpha: 0.35),
            blurRadius: 28,
            spreadRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Image.asset(
        'assets/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.confirmation_number_outlined,
          size: 48,
          color: Color(0xFF00C2FF),
        ),
      ),
    );
  }

  /// Tombol Portal yang bersih, rapi, dan responsif
  Widget _buildPortalButton({
    required BuildContext context,
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Label & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.chevron_right_rounded,
                  color: color.withValues(alpha: 0.6),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
