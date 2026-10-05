import 'package:flutter/material.dart';

import 'apps/hotel_partner/screens/splash/hotel_loading_screen.dart';
import 'apps/superadmin_go-ticket/screens/splash/super_admin_loading_screen.dart';
import 'apps/user/screens/splash/customer_loading_screen.dart';

void main() {
  runApp(const GoTicketApp());
}

class GoTicketApp extends StatelessWidget {
  const GoTicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PortalSelectionScreen(),
    );
  }
}

/// Layar pemilihan portal sederhana hitam putih (minimalis kaku)
class PortalSelectionScreen extends StatelessWidget {
  const PortalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              _buildSimpleButton(
                context: context,
                label: '1. User (Tamu)',
                destination: const CustomerLoadingScreen(),
              ),
              const SizedBox(height: 12),
              _buildSimpleButton(
                context: context,
                label: '2. Pihak Hotel',
                destination: const HotelLoadingScreen(),
              ),
              const SizedBox(height: 12),
              _buildSimpleButton(
                context: context,
                label: '3. Admin Go Ticket',
                destination: const SuperAdminLoadingScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleButton({
    required BuildContext context,
    required String label,
    required Widget destination,
  }) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.black, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Icon(Icons.arrow_forward, color: Colors.black, size: 18),
          ],
        ),
      ),
    );
  }
}
