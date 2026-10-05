// =============================================================================
// FILE: lib/apps/hotel_partner/screens/auth/staff_login_screen.dart
// RESPONSIBILITY: Halaman login untuk Staff Front Office dan Maintenance.
// Login menggunakan Username/Email + Password yang diberikan oleh Admin Hotel.
// (Login A — berbeda dengan Login B untuk Admin Hotel/Manager)
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../front_office/fo_dashboard_screen.dart';
import '../maintenance/maintenance_dashboard_screen.dart';
import 'admin_hotel_login_screen.dart';

/// Halaman login Staff (FO & Maintenance) Hotel Partner App.
class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // TODO: Integrasikan dengan AuthRepository.staffLogin()
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    // TODO: Role guard berdasarkan role dari response API
    // Untuk demo, navigasi ke FO Dashboard
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const FoDashboardScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 40),

                // Form login
                GoTicketTextField(
                  label: 'Username / Email',
                  hint: 'Masukkan username Anda',
                  controller: _usernameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => v!.isEmpty ? 'Username tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                GoTicketTextField(
                  label: 'Password',
                  hint: 'Masukkan password Anda',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: (v) => v!.isEmpty ? 'Password tidak boleh kosong' : null,
                  onSubmitted: _login,
                ),
                const SizedBox(height: 28),

                GoTicketButton(
                  label: 'Masuk',
                  onPressed: _isLoading ? null : _login,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 32),

                // Divider ke login Admin Hotel
                const Center(child: Text('Anda Admin Hotel / Manager?')),
                const SizedBox(height: 12),
                GoTicketOutlinedButton(
                  label: 'Masuk sebagai Admin Hotel',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminHotelLoginScreen()),
                  ),
                  icon: Icons.business_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.hotel_rounded, color: AppColors.white, size: 30),
        ),
        const SizedBox(height: 24),
        Text('Go Ticket', style: AppTextStyles.headlineMedium
            .copyWith(color: AppColors.primary)),
        Text('Portal Mitra Hotel', style: AppTextStyles.bodySmall),
        const SizedBox(height: 8),
        Text('Login Staff', style: AppTextStyles.displaySmall),
        const SizedBox(height: 6),
        Text(
          'Masukkan username dan password yang\ndiberikan oleh Admin Hotel Anda.',
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }
}
