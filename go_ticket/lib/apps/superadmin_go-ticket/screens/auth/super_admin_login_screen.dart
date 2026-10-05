// =============================================================================
// FILE: lib/apps/super_admin/screens/auth/super_admin_login_screen.dart
// RESPONSIBILITY: Halaman login Super Admin platform Go Ticket.
// Login menggunakan Email + Password untuk akun internal Go Ticket.
// Tampilan didesain enterprise/web-friendly dengan layout dua kolom.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../dashboard/super_admin_dashboard_screen.dart';

/// Halaman login Super Admin Go Ticket.
class SuperAdminLoginScreen extends StatefulWidget {
  const SuperAdminLoginScreen({super.key});

  @override
  State<SuperAdminLoginScreen> createState() => _SuperAdminLoginScreenState();
}

class _SuperAdminLoginScreenState extends State<SuperAdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: Integrasikan dengan AuthRepository.superAdminLogin()
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SuperAdminDashboardScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Layout responsif — dua kolom di layar lebar (web)
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Scaffold(
      backgroundColor: AppColors.grey950,
      body: isWide ? _buildWideLayout() : _buildNarrowLayout(),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Panel kiri — branding
        Expanded(
          flex: 1,
          child: Container(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.admin_panel_settings_rounded,
                    color: AppColors.white, size: 72),
                const SizedBox(height: 20),
                Text('Go Ticket',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.white,
                    )),
                Text('Super Admin Portal',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    )),
                const SizedBox(height: 32),
                Text(
                  'Platform Management Dashboard\nuntuk Tim Internal Go Ticket',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        // Panel kanan — form login
        Expanded(
          flex: 1,
          child: Center(child: _buildLoginForm(maxWidth: 400)),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _buildLoginForm(),
      ),
    );
  }

  Widget _buildLoginForm({double? maxWidth}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.admin_panel_settings_rounded,
                color: AppColors.primary, size: 48),
            const SizedBox(height: 16),
            Text('Super Admin Login',
                style: AppTextStyles.displaySmall),
            const SizedBox(height: 6),
            Text('Akses terbatas untuk tim internal Go Ticket.',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: 32),

            GoTicketTextField(
              label: 'Email',
              hint: 'admin@goticket.id',
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
            GoTicketTextField(
              label: 'Password',
              hint: '••••••••',
              controller: _passwordController,
              isPassword: true,
              prefixIcon: Icons.lock_outline_rounded,
              validator: (v) =>
                  v!.isEmpty ? 'Password tidak boleh kosong' : null,
              onSubmitted: _login,
            ),
            const SizedBox(height: 28),

            GoTicketButton(
              label: 'Masuk ke Dashboard',
              onPressed: _isLoading ? null : _login,
              isLoading: _isLoading,
              icon: Icons.login_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
