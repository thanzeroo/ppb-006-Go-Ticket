// =============================================================================
// FILE: lib/apps/hotel_partner/screens/auth/admin_hotel_login_screen.dart
// RESPONSIBILITY: Halaman login untuk Admin Hotel / Manager / Owner.
// Login B menggunakan kombinasi:
// - Hotel ID (ID unik hotel yang terdaftar di Go Ticket)
// - Email Bisnis
// - Password
// Berbeda dengan Login A (Staff) yang hanya butuh username + password.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../admin_hotel/executive_dashboard_screen.dart';

/// Halaman login Admin Hotel / Manager / Owner.
class AdminHotelLoginScreen extends StatefulWidget {
  const AdminHotelLoginScreen({super.key});

  @override
  State<AdminHotelLoginScreen> createState() => _AdminHotelLoginScreenState();
}

class _AdminHotelLoginScreenState extends State<AdminHotelLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hotelIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _hotelIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // TODO: Integrasikan dengan AuthRepository.adminHotelLogin()
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ExecutiveDashboardScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Login Admin Hotel'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Login ini khusus untuk Manager / Pemilik Hotel. '
                        'Gunakan Hotel ID yang diberikan saat pendaftaran hotel.',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Text('Masuk sebagai Admin Hotel',
                  style: AppTextStyles.headlineSmall),
              const SizedBox(height: 20),

              // Hotel ID
              GoTicketTextField(
                label: 'Hotel ID',
                hint: 'Contoh: HTL-001 atau GTHOTEL-2026-001',
                controller: _hotelIdController,
                prefixIcon: Icons.confirmation_number_outlined,
                validator: (v) =>
                    v!.isEmpty ? 'Hotel ID tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // Email bisnis
              GoTicketTextField(
                label: 'Email Bisnis',
                hint: 'manager@namahotel.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (v) {
                  if (v!.isEmpty) return 'Email tidak boleh kosong';
                  if (!v.contains('@')) return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password
              GoTicketTextField(
                label: 'Password',
                hint: 'Masukkan password akun',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: Icons.lock_outline_rounded,
                validator: (v) =>
                    v!.isEmpty ? 'Password tidak boleh kosong' : null,
                onSubmitted: _login,
              ),
              const SizedBox(height: 28),

              GoTicketButton(
                label: 'Masuk sebagai Admin Hotel',
                onPressed: _isLoading ? null : _login,
                isLoading: _isLoading,
                icon: Icons.business_center_outlined,
              ),
              const SizedBox(height: 20),

              // Lupa Hotel ID
              Center(
                child: GoTicketTextButton(
                  label: 'Lupa Hotel ID? Hubungi Go Ticket Support',
                  onPressed: () {},
                  icon: Icons.help_outline_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
