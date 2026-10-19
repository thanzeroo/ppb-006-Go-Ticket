import 'package:flutter/material.dart';

import 'apps/pihak_hotel/screens/splash/hotel_splash_screen.dart';
import 'apps/pihak_go_ticket/screens/splash/admin_splash_screen.dart';
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
      home: const PortalSelectionScreen(),
    );
  }
}

/// Layar pemilihan portal — pintu masuk ke 3 role utama.
class PortalSelectionScreen extends StatelessWidget {
  const PortalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              const Icon(Icons.confirmation_number_outlined,
                  size: 48, color: Color(0xFF00B4D8)),
              const SizedBox(height: 12),
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
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 40),

              _buildPortalButton(
                context: context,
                label: 'User (Tamu)',
                subtitle: 'Cari & booking hotel',
                icon: Icons.person_outline,
                color: const Color(0xFF00B4D8),
                destination: const CustomerLoadingScreen(),
              ),
              const SizedBox(height: 12),
              _buildPortalButton(
                context: context,
                label: 'Pihak Hotel',
                subtitle: 'Kelola hotel mitra',
                icon: Icons.hotel_outlined,
                color: const Color(0xFF0D3B55),
                destination: const HotelSplashScreen(),
              ),
              const SizedBox(height: 12),
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
    );
  }

  Widget _buildPortalButton({
    required BuildContext context,
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return Material(
      color: color.withOpacity(0.05),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
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
              Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
