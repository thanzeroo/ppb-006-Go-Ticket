// =============================================================================
// FILE: lib/apps/superadmin_go-ticket/screens/auth/super_admin_login_screen.dart
// RESPONSIBILITY: Layar Login Super Admin Platform Go Ticket.
// Tampilan presisi sesuai desain mockup: Banner otorisasi level 1, ID Admin,
// Master Security Key, input token 2FA (TOTP), audit trail AES-256,
// dan verifikasi IP otoritas.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/widgets/auth_logo_header.dart';
import '../dashboard/super_admin_dashboard_screen.dart';

class SuperAdminLoginScreen extends StatefulWidget {
  const SuperAdminLoginScreen({super.key});

  @override
  State<SuperAdminLoginScreen> createState() => _SuperAdminLoginScreenState();
}

class _SuperAdminLoginScreenState extends State<SuperAdminLoginScreen> {
  final _emailController =
      TextEditingController(text: 'admin.master@goticket.id');
  final _passwordController =
      TextEditingController(text: 'SuperSecret2025!');

  bool _obscurePassword = true;
  bool _rememberSession = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Otorisasi dan masuk ke Super Admin Dashboard
  Future<void> _submit() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SuperAdminDashboardScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Navigator.canPop(context)
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Pilih Portal Lain',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Banner Portal Sentral Super Admin Level 1
              _buildTopLevelBanner(),
              const SizedBox(height: 18),

              // Logo dengan cyan glow
              const AuthLogoHeader(),
              const SizedBox(height: 18),

              // Judul & Subjudul
              const Text(
                'LOGIN ADMIN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Otorisasi panel kendali manajemen penginapan, kontrol\nstaf, pengguna, dan analitik finansial Go Ticket.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Form Input Kredensial Admin
              _buildSuperAdminForm(),
              const SizedBox(height: 20),

              // Kartu Audit Trail Keamanan
              _buildAuditTrailCard(),
              const SizedBox(height: 14),

              // Tombol Bantuan Tim Teknis
              _buildTechSupportButton(),
              const SizedBox(height: 14),

              // Info IP Otoritas
              const Text(
                'IP Otoritas: 180.252.164.20 (Jakarta Gateway Secured)',
                style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGETS
  // ---------------------------------------------------------------------------

  Widget _buildTopLevelBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.circle, size: 7, color: Color(0xFF2563EB)),
          SizedBox(width: 6),
          Text(
            'PORTAL SENTRAL SUPER ADMIN • TINGKAT OTORISASI LEVEL 1',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2563EB),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuperAdminForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email / ID Super Admin
        _buildInputLabel('Email / ID Super Admin'),
        _buildTextField(
          controller: _emailController,
          hintText: 'admin.master@goticket.id',
          prefixIcon: Icons.admin_panel_settings_outlined,
        ),
        const SizedBox(height: 16),

        // Master Security Key
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Master Security Key / Password',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
            Text(
              'Kunci Vault Utama',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _passwordController,
          hintText: 'SuperSecret2025!',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18,
              color: const Color(0xFF94A3B8),
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 16),

        // 2FA / TOTP Box
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.shield_outlined, size: 14, color: Color(0xFF0284C7)),
                SizedBox(width: 4),
                Text(
                  'Kode Autentikasi 2FA / Token',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                ),
              ],
            ),
            Row(
              children: const [
                Icon(Icons.lock_outline_rounded, size: 13, color: Color(0xFF0284C7)),
                SizedBox(width: 4),
                Text(
                  'Hardware Token / TOTP',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildTokenBoxes(['8', '3', '9', '2', '–', '–']),
        const SizedBox(height: 14),

        // Switch Sesi Resmi
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Ingat Sesi di Perangkat Resmi',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 2),
                Text(
                  'Otorisasi terminal hotel terverifikasi (12 jam)',
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
            Switch(
              value: _rememberSession,
              activeThumbColor: const Color(0xFF00C7F2),
              onChanged: (v) => setState(() => _rememberSession = v),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tombol Otorisasi & Buka Dashboard
        _buildAuthButton(),
      ],
    );
  }

  Widget _buildTokenBoxes(List<String> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: values.map((val) {
        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              val,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAuthButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C7F2), Color(0xFF026786)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF026786).withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.shield_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Otorisasi & Buka Dashboard',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _buildAuditTrailCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shield_rounded, size: 18, color: Color(0xFF0369A1)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'AUDIT TRAIL KEAMANAN AKTIF',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Dilindungi Enkripsi AES–256 & Audit Trail Transaksi Realtime. Setiap aktivitas login dan modifikasi data admin dicatat secara permanen ke server log.',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechSupportButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.headset_mic_outlined, size: 16, color: Color(0xFF0F172A)),
          SizedBox(width: 8),
          Text(
            'Hubungi Tim Teknis & Keamanan Server',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF0284C7), size: 18),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}
