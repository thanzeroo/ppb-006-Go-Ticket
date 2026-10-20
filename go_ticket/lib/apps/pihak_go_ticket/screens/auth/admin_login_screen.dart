import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dashboard/admin_dashboard_screen.dart';

/// Layar Login Super Admin untuk Pihak Go Ticket.
/// Desain visual presisi sesuai foto dengan otorisasi 2FA & Audit Trail.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController(text: 'admin.master@goticket.id');
  final _passwordController = TextEditingController(text: 'SuperSecret2025!');

  // PIN 6 digit untuk 2FA
  final List<TextEditingController> _pinControllers = List.generate(
    6,
    (index) => TextEditingController(
      text: index == 0
          ? '8'
          : index == 1
              ? '3'
              : index == 2
                  ? '9'
                  : index == 3
                      ? '2'
                      : '',
    ),
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
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
    );
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Badge Status
              _buildTopBadge(),
              const SizedBox(height: 18),

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
              const SizedBox(height: 18),

              // Card Audit Trail Keamanan Aktif
              _buildAuditTrailCard(),
              const SizedBox(height: 16),

              // Pill Button Hubungi Tim Teknis & Keamanan Server
              _buildSupportButton(),
              const SizedBox(height: 12),

              // Footer IP Otoritas
              const Text(
                'IP Otoritas: 180.252.164.20 (Jakarta Gateway Secured)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGETS
  // ---------------------------------------------------------------------------

  /// Top Badge Status: PORTAL SENTRAL SUPER ADMIN • TINGKAT OTORISASI LEVEL 1
  Widget _buildTopBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF0FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF00C2FF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'PORTAL SENTRAL SUPER ADMIN • TINGKAT OTORISASI LEVEL 1',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E40AF),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

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
        // 1. Email / ID Super Admin
        Row(
          children: const [
            Icon(Icons.badge_outlined, size: 16, color: Color(0xFF0096B4)),
            SizedBox(width: 6),
            Text(
              'Email / ID Super Admin',
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
          hint: 'admin.master@goticket.id',
          icon: Icons.shield_outlined,
        ),
        const SizedBox(height: 16),

        // 2. Master Security Key / Password
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.vpn_key_outlined, size: 16, color: Color(0xFF0096B4)),
                SizedBox(width: 6),
                Text(
                  'Master Security Key / Password',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Akses Kunci Vault Utama diverifikasi ke HSM Server.'),
                    backgroundColor: Color(0xFF006D84),
                  ),
                );
              },
              child: const Text(
                'Kunci Vault Utama',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0284C7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _buildInputField(
          controller: _passwordController,
          hint: 'SuperSecret2025!',
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

        // 3. Kode Autentikasi 2FA / Token
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF0096B4)),
                SizedBox(width: 6),
                Text(
                  'Kode Autentikasi 2FA /\nToken',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    height: 1.2,
                  ),
                ),
              ],
            ),
            Row(
              children: const [
                Icon(Icons.lock_outline, size: 14, color: Color(0xFF00809A)),
                SizedBox(width: 4),
                Text(
                  'Hardware Token /\nTOTP',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00809A),
                    height: 1.2,
                  ),
                ),
              ],
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

  /// Card: AUDIT TRAIL KEAMANAN AKTIF
  Widget _buildAuditTrailCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_rounded,
            color: Color(0xFF0284C7),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'AUDIT TRAIL KEAMANAN AKTIF',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Dilindungi Enkripsi AES-256 & Audit Trail Transaksi Realtime. Setiap aktivitas login dan modifikasi data admin dicatat secara permanen ke server log.',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Support Button: Hubungi Tim Teknis & Keamanan Server
  Widget _buildSupportButton() {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menghubungkan ke NOC & Tim Keamanan Server...'),
            backgroundColor: Color(0xFF0F172A),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FD),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.headset_mic_outlined,
              size: 17,
              color: Color(0xFFDC2626),
            ),
            SizedBox(width: 8),
            Text(
              'Hubungi Tim Teknis & Keamanan Server',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
