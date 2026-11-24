import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/auth_service.dart';
import '../dashboard/admin_dashboard_screen.dart';

/// Layar Login Super Admin untuk Pihak Go Ticket.
/// Desain visual presisi sesuai foto dengan otorisasi 2FA & Audit Trail.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // PIN 6 digit untuk 2FA
  final List<TextEditingController> _pinControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _pinFocusNodes = List.generate(6, (_) => FocusNode());

  bool _rememberSession = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    for (final c in _pinControllers) {
      c.dispose();
    }
    for (final f in _pinFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final pin = _pinControllers.map((c) => c.text.trim()).join();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan email'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan password'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (pin.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode autentikasi wajib diisi 6 digit (angka acak/bebas)'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.loginSuperAdmin(
        email: email,
        password: password,
        pin2FA: pin,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('❌ [AdminLoginScreen] Error: $e');
      String msg = e.toString().replaceFirst('Exception: ', '');
      if (msg.toLowerCase().contains('invalid login credentials')) {
        msg = 'Email atau kata sandi salah';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFD),
      appBar: Navigator.canPop(context)
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF1E293B),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Pilih Portal',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Box dengan Cyan Glow
                _buildLogoHeader(),
                const SizedBox(height: 18),

                // Judul Utama
                const Text(
                  'LOGIN ADMIN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Otorisasi panel kendali manajemen penginapan, kontrol staf, pengguna, dan analitik finansial Go Ticket.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),

                // Main Card Form Container
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGETS
  // ---------------------------------------------------------------------------

  /// Logo Box dengan Cyan Glow
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
      padding: const EdgeInsets.all(10),
      child: Image.asset(
        'assets/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.admin_panel_settings_rounded,
          size: 48,
          color: Color(0xFF00C2FF),
        ),
      ),
    );
  }

  /// Form Utama Super Admin
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Email
        Row(
          children: const [
            Icon(Icons.email_outlined, size: 16, color: Color(0xFF0096B4)),
            SizedBox(width: 6),
            Text(
              'Email',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _buildInputField(
          controller: _emailController,
          hint: 'Masukkan email',
          icon: Icons.alternate_email_rounded,
        ),
        const SizedBox(height: 16),

        // 2. Password
        Row(
          children: const [
            Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF0096B4)),
            SizedBox(width: 6),
            Text(
              'Password',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _buildInputField(
          controller: _passwordController,
          hint: 'Masukkan password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 19,
              color: const Color(0xFF64748B),
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 16),

        // 3. Kode Autentikasi
        Row(
          children: const [
            Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF0096B4)),
            SizedBox(width: 6),
            Text(
              'Kode Autentikasi',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 6 Digit PIN Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _buildPinBox(i)),
        ),
        const SizedBox(height: 18),

        // 4. Ingat Sesi di Perangkat Resmi
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Ingat Sesi di Perangkat Resmi',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Otorisasi terminal hotel terverifikasi (12 jam)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 24,
              child: Switch(
                value: _rememberSession,
                thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
                  return Colors.white;
                }),
                activeTrackColor: const Color(0xFF00C2FF),
                inactiveTrackColor: const Color(0xFFE2E8F0),
                onChanged: (val) => setState(() => _rememberSession = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 5. Tombol Otorisasi & Buka Dashboard
        _buildGradientSubmitButton(),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF64748B),
            size: 19,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  /// Kotak Input PIN 2FA
  Widget _buildPinBox(int index) {
    final controller = _pinControllers[index];
    final focusNode = _pinFocusNodes[index];
    final isFilled = controller.text.isNotEmpty;

    return Container(
      width: 44,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFilled ? const Color(0xFF00C2FF) : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: '-',
            hintStyle: TextStyle(
              fontSize: 18,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.bold,
            ),
          ),
          onChanged: (val) {
            setState(() {});
            if (val.isNotEmpty && index < 5) {
              _pinFocusNodes[index + 1].requestFocus();
            } else if (val.isEmpty && index > 0) {
              _pinFocusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }

  /// Tombol Gradient Cyan -> Dark Teal
  Widget _buildGradientSubmitButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00C2FF),
            Color(0xFF005E76),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C2FF).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.verified_user_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Otorisasi & Buka Dashboard',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
      ),
    );
  }
}
