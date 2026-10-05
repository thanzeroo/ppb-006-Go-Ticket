import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'apps/hotel_partner/screens/auth/staff_login_screen.dart';
import 'apps/superadmin_go-ticket/screens/auth/super_admin_login_screen.dart';
import 'apps/user/screens/splash/customer_loading_screen.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const GoTicketApp());
}

class GoTicketApp extends StatelessWidget {
  const GoTicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Go Ticket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const PortalSelectionScreen(),
    );
  }
}

/// Layar pemilihan portal aplikasi: User (Tamu), Pihak Hotel, dan Admin Go Ticket.
class PortalSelectionScreen extends StatelessWidget {
  const PortalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo & Judul Aplikasi
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.confirmation_number_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Go Ticket',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sistem Pemesanan Hotel & Manajemen Mitra',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Instruksi
                  const Text(
                    'PILIH PORTAL AKSES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Opsi 1: User (Tamu)
                  _buildPortalCard(
                    context: context,
                    badge: 'Customer App',
                    badgeColor: AppColors.primary,
                    icon: Icons.person_rounded,
                    iconBgColor: AppColors.primary,
                    title: 'User (Tamu)',
                    description:
                        'Pencarian hotel, booking kamar, e-ticket, dan ulasan.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomerLoadingScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Opsi 2: Pihak Hotel
                  _buildPortalCard(
                    context: context,
                    badge: 'Mitra Hotel',
                    badgeColor: AppColors.secondary,
                    icon: Icons.hotel_rounded,
                    iconBgColor: AppColors.secondary,
                    title: 'Pihak Hotel',
                    description:
                        'Front Office (Check-in/out), Housekeeping, & Admin Hotel.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StaffLoginScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Opsi 3: Admin Go Ticket
                  _buildPortalCard(
                    context: context,
                    badge: 'Super Admin',
                    badgeColor: const Color(0xFF7C3AED),
                    icon: Icons.admin_panel_settings_rounded,
                    iconBgColor: const Color(0xFF7C3AED),
                    title: 'Admin Go Ticket',
                    description:
                        'Super Admin Platform, verifikasi hotel, dan approval payout.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SuperAdminLoginScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 36),

                  // Footer
                  const Text(
                    'Go Ticket Platform v1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortalCard({
    required BuildContext context,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey200, width: 1.2),
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBgColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconBgColor, size: 28),
              ),
              const SizedBox(width: 16),

              // Teks informasi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey900,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.grey400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
