// =============================================================================
// FILE: lib/apps/customer/screens/auth/customer_login_screen.dart
// RESPONSIBILITY: Halaman login untuk Customer (Tamu) Go Ticket.
// Mendukung dua metode autentikasi:
// 1. Nomor HP + OTP (via SMS)
// 2. Google Sign In (OAuth2)
// Alur OTP: Masukkan HP → Kirim OTP → Masukkan 6-digit kode → Login sukses
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../dashboard/customer_dashboard_screen.dart';

/// Halaman login Customer dengan OTP HP atau Google Sign In.
class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  /// Apakah sedang menampilkan form input OTP (setelah HP disubmit)
  bool _showOtpForm = false;

  /// Apakah sedang memproses request (loading state)
  bool _isLoading = false;

  /// Countdown timer untuk tombol 'Kirim Ulang OTP'
  int _resendCountdown = 0;

  // Form controllers
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  /// Kirim OTP ke nomor HP yang diinput
  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: Integrasikan dengan AuthRepository.requestOtp()
    await Future.delayed(const Duration(seconds: 2)); // Simulasi API call

    setState(() {
      _isLoading = false;
      _showOtpForm = true;
      _resendCountdown = 60;
    });

    _startResendCountdown();
  }

  /// Verifikasi kode OTP dan login
  Future<void> _verifyOtpAndLogin() async {
    if (_otpController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan 6 digit kode OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Integrasikan dengan AuthRepository.verifyOtpAndLogin()
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Navigasi ke Dashboard setelah login sukses
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()),
      (_) => false,
    );
  }

  /// Login dengan Google Sign In
  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);

    // TODO: Integrasikan dengan Google Sign In SDK dan AuthRepository
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()),
      (_) => false,
    );
  }

  /// Countdown timer untuk tombol kirim ulang OTP
  void _startResendCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCountdown--);
      return _resendCountdown > 0;
    });
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Logo & Tagline
                _buildHeader(),
                const SizedBox(height: 40),

                // Form input (HP atau OTP)
                _showOtpForm ? _buildOtpForm() : _buildPhoneForm(),

                const SizedBox(height: 32),

                // Divider OR
                if (!_showOtpForm) _buildDivider(),

                // Google Sign In Button
                if (!_showOtpForm) ...[
                  const SizedBox(height: 16),
                  _buildGoogleButton(),
                ],

                const SizedBox(height: 32),

                // Footer teks syarat & ketentuan
                _buildFooter(),
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
        // Logo Go Ticket
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.hotel_rounded, color: AppColors.white, size: 28),
        ),
        const SizedBox(height: 24),

        Text(
          _showOtpForm ? 'Masukkan Kode OTP' : 'Selamat Datang!',
          style: AppTextStyles.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          _showOtpForm
              ? 'Kode 6 digit telah dikirim ke\n${_phoneController.text}'
              : 'Masuk atau daftar ke Go Ticket\nuntuk memesan hotel dengan mudah.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GoTicketTextField(
          label: 'Nomor Handphone',
          hint: 'Contoh: 08123456789',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 13,
          textInputAction: TextInputAction.done,
          onSubmitted: _requestOtp,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nomor HP tidak boleh kosong';
            }
            if (value.length < 10) {
              return 'Nomor HP minimal 10 digit';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        GoTicketButton(
          label: 'Kirim Kode OTP',
          onPressed: _isLoading ? null : _requestOtp,
          isLoading: _isLoading,
          icon: Icons.sms_outlined,
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GoTicketTextField(
          label: 'Kode OTP',
          hint: '_ _ _ _ _ _',
          controller: _otpController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 6,
          textInputAction: TextInputAction.done,
          onSubmitted: _verifyOtpAndLogin,
        ),
        const SizedBox(height: 12),

        // Tombol kirim ulang OTP
        Row(
          children: [
            Text(
              'Tidak menerima kode? ',
              style: AppTextStyles.bodySmall,
            ),
            _resendCountdown > 0
                ? Text(
                    'Kirim ulang (${_resendCountdown}s)',
                    style: AppTextStyles.labelSmall,
                  )
                : GoTicketTextButton(
                    label: 'Kirim Ulang',
                    onPressed: _requestOtp,
                  ),
          ],
        ),

        const SizedBox(height: 24),
        GoTicketButton(
          label: 'Masuk',
          onPressed: _isLoading ? null : _verifyOtpAndLogin,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 12),
        GoTicketOutlinedButton(
          label: 'Ganti Nomor HP',
          onPressed: () => setState(() {
            _showOtpForm = false;
            _otpController.clear();
          }),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.grey200)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('atau', style: AppTextStyles.bodySmall),
        ),
        const Expanded(child: Divider(color: AppColors.grey200)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return GoTicketSocialButton(
      label: 'Masuk dengan Google',
      onPressed: _isLoading ? null : _googleSignIn,
      isLoading: false,
      icon: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.grey100,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.g_mobiledata, size: 18, color: AppColors.primary),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'Dengan masuk, Anda menyetujui\nSyarat & Ketentuan serta Kebijakan Privasi Go Ticket.',
        style: AppTextStyles.caption,
        textAlign: TextAlign.center,
      ),
    );
  }
}
