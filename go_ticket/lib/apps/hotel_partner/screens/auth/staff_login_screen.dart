// =============================================================================
// FILE: lib/apps/hotel_partner/screens/auth/staff_login_screen.dart
// RESPONSIBILITY: Layar Login Mitra Hotel yang mencakup 3 peran operasional:
// 1. Maintenance (Portal Operasional Maintenance)
// 2. Staff (Portal Operasional Staf Front Office)
// 3. Administrator (Portal Administrator Hotel)
// Tampilan presisi sesuai desain mockup: Role switcher pill, shift selector,
// validasi biometrik & kredensial perbankan / escrow.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/widgets/auth_logo_header.dart';
import '../admin_hotel/executive_dashboard_screen.dart';
import '../front_office/fo_dashboard_screen.dart';
import '../maintenance/maintenance_dashboard_screen.dart';

class StaffLoginScreen extends StatefulWidget {
  /// 0 = Maintenance, 1 = Staff, 2 = Administrator
  final int initialRole;

  const StaffLoginScreen({super.key, this.initialRole = 1});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  late int _roleIndex;

  // Controllers untuk Staff & Maintenance
  final _staffIdController = TextEditingController(text: 'STF-2025-084');
  final _staffPasswordController =
      TextEditingController(text: 'HotelMaintenancePass@2025');

  // Controllers untuk Administrator Hotel
  final _adminEmailController =
      TextEditingController(text: 'admingrandamora@hotel');
  final _adminPasswordController = TextEditingController(text: 'secretpassword');

  // State form
  int _selectedShift = 0; // 0 = Pagi, 1 = Sore, 2 = Malam
  bool _rememberDevice = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _roleIndex = widget.initialRole;
  }

  @override
  void dispose() {
    _staffIdController.dispose();
    _staffPasswordController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  /// Proses login sesuai peran yang dipilih
  Future<void> _submit() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isLoading = false);

    Widget targetDashboard;
    if (_roleIndex == 0) {
      targetDashboard = const MaintenanceDashboardScreen();
    } else if (_roleIndex == 1) {
      targetDashboard = const FoDashboardScreen();
    } else {
      targetDashboard = const ExecutiveDashboardScreen();
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => targetDashboard),
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
              // Badge Atas (Khusus Staff & Maintenance)
              if (_roleIndex != 2) ...[
                _buildSystemBadge(),
                const SizedBox(height: 12),
              ],

              // Logo dengan cyan glow & logo Hotel
              const AuthLogoHeader(imagePath: 'assets/logo_hotel.png'),
              const SizedBox(height: 14),

              // Badge Role Administrator (Khusus Admin)
              if (_roleIndex == 2) ...[
                _buildRoleBadge('👤 Role Administrator'),
                const SizedBox(height: 10),
              ],

              // Judul & Subjudul
              _buildTitleAndSubtitle(),
              const SizedBox(height: 18),

              // Role Switcher Tab: [ Maintenance ] [ Staff ] [ Administrator ]
              _buildRoleSwitcher(),
              const SizedBox(height: 20),

              // Form sesuai Role
              _roleIndex == 2 ? _buildAdminForm() : _buildStaffMaintenanceForm(),
              const SizedBox(height: 24),

              // Bagian Bawah / Info Keamanan Tambahan
              _buildFooterInfo(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER COMPONENTS
  // ---------------------------------------------------------------------------

  Widget _buildSystemBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.shield_outlined, size: 13, color: Color(0xFF0284C7)),
          SizedBox(width: 5),
          Text(
            'SISTEM AKSES INTERNAL HOTEL V3.12',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0284C7),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle() {
    String title;
    String? subtitle;

    if (_roleIndex == 0) {
      title = 'Portal Operasional Maintenance';
      subtitle = 'Silakan masuk menggunakan ID Petugas dan PIN / Sandi terdaftar.';
    } else if (_roleIndex == 1) {
      title = 'Portal Operasional Staf';
      subtitle = 'Silakan masuk menggunakan ID Petugas dan PIN / Sandi terdaftar.';
    } else {
      title = 'Portal Administrator Hotel';
      subtitle = null;
    }

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ROLE SWITCHER
  // ---------------------------------------------------------------------------

  Widget _buildRoleSwitcher() {
    return Row(
      children: [
        Expanded(child: _buildRoleTabItem(title: 'Maintenance', index: 0)),
        const SizedBox(width: 8),
        Expanded(child: _buildRoleTabItem(title: 'Staff', index: 1)),
        const SizedBox(width: 8),
        Expanded(child: _buildRoleTabItem(title: 'Administrator', index: 2)),
      ],
    );
  }

  Widget _buildRoleTabItem({required String title, required int index}) {
    final isSelected = _roleIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _roleIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7DD3FC) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF00C7F2) : const Color(0xFFCBD5E1),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00C7F2).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? const Color(0xFF0369A1) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STAFF & MAINTENANCE FORM
  // ---------------------------------------------------------------------------

  Widget _buildStaffMaintenanceForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('ID Petugas / NIK Staf *'),
        _buildTextField(
          controller: _staffIdController,
          hintText: 'STF-2025-084',
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 14),

        _buildInputLabel('Kata Sandi / Kredensial Keamanan *'),
        _buildTextField(
          controller: _staffPasswordController,
          hintText: 'HotelMaintenancePass@2025',
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

        // Pilihan Shift
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Pilih Shift Tugas',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
            Text(
              'Wajib Dipilih',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        _buildShiftCard(
          index: 0,
          title: 'Shift Pagi',
          time: '07:00 – 15:00 WIB',
          icon: Icons.wb_sunny_outlined,
        ),
        const SizedBox(height: 8),
        _buildShiftCard(
          index: 1,
          title: 'Shift Sore',
          time: '15:00 – 23:00 WIB',
          icon: Icons.wb_twilight_rounded,
        ),
        const SizedBox(height: 8),
        _buildShiftCard(
          index: 2,
          title: 'Shift Malam',
          time: '23:00 – 07:00 WIB',
          icon: Icons.nightlight_round,
        ),
        const SizedBox(height: 14),

        // Switch Ingat Kredensial
        Row(
          children: [
            const Icon(Icons.computer_rounded, size: 18, color: Color(0xFF64748B)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Ingat kredensial di perangkat hotel ini',
                style: TextStyle(fontSize: 11, color: Color(0xFF475569)),
              ),
            ),
            Switch(
              value: _rememberDevice,
              activeThumbColor: const Color(0xFF00C7F2),
              onChanged: (v) => setState(() => _rememberDevice = v),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Tombol Submit
        _buildPrimaryButton(
          title: 'Masuk ke Dashboard Operasional',
          onTap: _submit,
        ),
      ],
    );
  }

  Widget _buildShiftCard({
    required int index,
    required String title,
    required String time,
    required IconData icon,
  }) {
    final isSelected = _selectedShift == index;
    return InkWell(
      onTap: () => setState(() => _selectedShift = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00C7F2) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: const Color(0xFF0284C7)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C7F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Text(
                      'Aktif',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.check, size: 12, color: Colors.white),
                  ],
                ),
              )
            else
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ADMINISTRATOR FORM
  // ---------------------------------------------------------------------------

  Widget _buildAdminForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kartu Properti Hotel Terpilih
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🏢 PROPERTI HOTEL TERPILIH',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0284C7),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'The Grand Amora Resort',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Bali Regency • #PROP-2025-089',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      children: const [
                        Text(
                          'Ganti',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.swap_horiz_rounded, size: 14, color: Color(0xFF0284C7)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Email Administrator / ID Manajer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            Text('Akses Terotorisasi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0284C7))),
          ],
        ),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _adminEmailController,
          hintText: 'admingrandamora@hotel',
          prefixIcon: Icons.mail_outline_rounded,
        ),
        const SizedBox(height: 14),

        _buildInputLabel('Kata Sandi / Master Password'),
        _buildTextField(
          controller: _adminPasswordController,
          hintText: '••••••••••••',
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

        // PIN 6-Digit
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('PIN OTORISASI KEUANGAN 6–DIGIT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            Text('Opsional (2FA)', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
        const SizedBox(height: 8),
        _buildPinBoxes(['7', '2', '9', '•', '•', '•']),
        const SizedBox(height: 12),

        // Checkbox & Lupa Kata Sandi
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: _rememberDevice,
                    activeColor: const Color(0xFF00C7F2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: const BorderSide(color: Color(0xFF00C7F2), width: 1.5),
                    onChanged: (v) => setState(() => _rememberDevice = v ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Ingat di perangkat ini', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
            const Text(
              'Lupa Kata Sandi?',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tombol Submit Administrator
        _buildPrimaryButton(
          title: 'Masuk sebagai Administrator Hotel',
          onTap: _submit,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------

  Widget _buildPinBoxes(List<String> values) {
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
          ),
        );
      }).toList(),
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

  Widget _buildPrimaryButton({required String title, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C7F2),
          elevation: 0,
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
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _buildFooterInfo() {
    if (_roleIndex == 0) {
      // Maintenance Footer Info
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_user_outlined, size: 18, color: Color(0xFF0284C7)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Validasi Biometrik & Perangkat',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Sistem mendeteksi workstation internal (Front-Desk Terminal A-03). Pastikan Anda melakukan serah terima shift secara resmi.',
                        style: TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.support_agent_rounded, size: 16, color: Color(0xFF0284C7)),
                SizedBox(width: 8),
                Text(
                  'Hubungi Admin IT / Supervisor Resepsionis',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Enkripsi Keamanan End-to-End • Standar Operasional Perhotelan\nPT Go Ticket Ekosistem Hospitality © 2025',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), height: 1.4),
          ),
        ],
      );
    } else if (_roleIndex == 1) {
      // Staff Footer Info
      return const Text(
        'PT Go Ticket © 2026',
        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
      );
    } else {
      // Administrator Footer Info
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.circle, size: 8, color: Color(0xFF0284C7)),
              SizedBox(width: 6),
              Text(
                'SSL 256–bit Encrypted Session Active',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              ),
              SizedBox(width: 6),
              Icon(Icons.shield_outlined, size: 12, color: Color(0xFF0284C7)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.headset_mic_outlined, size: 16, color: Color(0xFF0284C7)),
                SizedBox(width: 8),
                Text(
                  'Bantuan IT & Hotline GM: +62 811–3829–001',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sistem Terintegrasi Go Ticket HQ Escrow & Channel Manager\n© 2025 Go Ticket Ops',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), height: 1.4),
          ),
        ],
      );
    }
  }
}
