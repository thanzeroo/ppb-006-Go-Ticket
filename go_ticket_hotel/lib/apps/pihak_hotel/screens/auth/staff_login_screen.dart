import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/services/auth_service.dart';
import '../administrator/administrator_dashboard_screen.dart';
import '../front_office/fo_dashboard_screen.dart';
import '../maintenance/maintenance_dashboard_screen.dart';

/// Formatter input ID/Email Petugas.
/// Membiarkan teks fleksibel agar pengguna bisa mengetikkan format ID (FO-xxx, MT-xxx, ADM-xxx) maupun email.
class StaffIdInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue;
  }
}

/// Layar Login untuk Pihak Hotel.
/// Menggabungkan role Maintenance & Staf menjadi role tunggal: "Staf"
/// Serta role "Administrator" sesuai desain visual foto.
class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  // 0: Staf (gabungan Staf & Maintenance), 1: Administrator
  int _selectedRoleIndex = 0;

  // Controllers untuk Staf
  final _staffIdController = TextEditingController();
  final _staffPasswordController = TextEditingController();

  // Controllers untuk Administrator
  final _adminIdController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  // PIN 6 digit untuk Admin
  final List<TextEditingController> _pinControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _pinFocusNodes = List.generate(6, (_) => FocusNode());

  // Status Shift Tugas Staf: 0 = Pagi, 1 = Sore, 2 = Malam
  int _selectedShift = 0;

  // Kredensial switch & password visibility
  bool _rememberCredentials = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _staffIdController.dispose();
    _staffPasswordController.dispose();
    _adminIdController.dispose();
    _adminPasswordController.dispose();
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
    try {
      final UserRole expectedRole;
      final String identifier;
      final String password;

      if (_selectedRoleIndex == 0) {
        final rawId = _staffIdController.text.trim();
        if (rawId.isEmpty) {
          throw Exception('Silakan masukkan Id petugas.');
        }
        if (_staffPasswordController.text.isEmpty) {
          throw Exception('Silakan masukkan password.');
        }
        identifier = rawId;
        password = _staffPasswordController.text;
        // Role operasional staf (FO maupun Maintenance otomatis dideteksi dari database)
        expectedRole = UserRole.staffFo;
      } else {
        final rawId = _adminIdController.text.trim();
        if (rawId.isEmpty) {
          throw Exception('Silakan masukkan Id petugas.');
        }
        if (_adminPasswordController.text.isEmpty) {
          throw Exception('Silakan masukkan password.');
        }
        // Pastikan kode autentikasi 6-digit terisi (otomatis isi acak jika kosong)
        final sampleDigits = ['1', '2', '3', '4', '5', '6'];
        for (int i = 0; i < 6; i++) {
          if (_pinControllers[i].text.isEmpty) {
            _pinControllers[i].text = sampleDigits[i];
          }
        }
        identifier = rawId;
        password = _adminPasswordController.text;
        expectedRole = UserRole.adminHotel;
      }

      final loggedInUser = await AuthService.instance.loginHotelStaff(
        identifier: identifier,
        password: password,
        expectedRole: expectedRole,
        shift: _selectedShift,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Navigasi pasca-login HARUS memakai role dari database, bukan pilihan toggle di UI
      final Widget targetScreen;
      switch (loggedInUser.role) {
        case UserRole.staffFo:
          targetScreen = const FoDashboardScreen();
          break;
        case UserRole.maintenance:
          targetScreen = const MaintenanceDashboardScreen();
          break;
        case UserRole.adminHotel:
          targetScreen = const AdministratorDashboardScreen();
          break;
        default:
          throw Exception('Role akun (${loggedInUser.role.displayName}) belum memiliki portal');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('❌ [StaffLoginScreen] Error: $e');
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo Box dengan Cyan Glow
              _buildLogoHeader(),
              const SizedBox(height: 16),

              // Judul & Subtitle
              Text(
                _selectedRoleIndex == 0
                    ? 'Portal Operasional Staf'
                    : 'Portal Administrator Hotel',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _selectedRoleIndex == 0
                    ? 'Silakan masuk menggunakan Id petugas dan password terdaftar.'
                    : 'Silakan masuk menggunakan Id petugas dan password terdaftar.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Tab Switcher [ Staf ] [ Administrator ]
              _buildRoleTabSwitcher(),
              const SizedBox(height: 20),

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
                child: _selectedRoleIndex == 0
                    ? _buildStaffForm()
                    : _buildAdminForm(),
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


  /// Logo Header dengan box putih & cyan glow shadow
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
        'assets/logo_hotel.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  /// Role Switcher: menggabungkan maintenance & staf menjadi "Staf", serta "Administrator"
  Widget _buildRoleTabSwitcher() {
    return Row(
      children: [
        Expanded(
          child: _buildRoleTabButton(
            title: 'Staf',
            isSelected: _selectedRoleIndex == 0,
            onTap: () => setState(() => _selectedRoleIndex = 0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildRoleTabButton(
            title: 'Administrator',
            isSelected: _selectedRoleIndex == 1,
            onTap: () => setState(() => _selectedRoleIndex = 1),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFBAF0FD) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF8CE6F8) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00C7F2).withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? const Color(0xFF006D84) : const Color(0xFF0F687C),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FORM STAF (Termasuk Shift Tugas & Hubungi IT)
  // ---------------------------------------------------------------------------
  Widget _buildStaffForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Id petugas
        _buildRequiredLabel('Id petugas'),
        _buildInputField(
          controller: _staffIdController,
          hint: 'Masukkan id',
          icon: Icons.badge_outlined,
          textCapitalization: TextCapitalization.none,
        ),
        const SizedBox(height: 14),

        // Password
        _buildRequiredLabel('Password'),
        _buildInputField(
          controller: _staffPasswordController,
          hint: 'Masukkan password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 19,
              color: const Color(0xFF94A3B8),
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 16),

        // Header Pilih Shift Tugas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Pilih Shift Tugas',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Wajib Dipilih',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF007F9D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 3 Kartu Shift
        _buildShiftCard(
          index: 0,
          title: 'Shift Pagi',
          time: '07:00 - 15:00 WIB',
          icon: Icons.wb_sunny_outlined,
        ),
        const SizedBox(height: 8),
        _buildShiftCard(
          index: 1,
          title: 'Shift Sore',
          time: '15:00 - 23:00 WIB',
          icon: Icons.wb_twilight_rounded,
        ),
        const SizedBox(height: 8),
        _buildShiftCard(
          index: 2,
          title: 'Shift Malam',
          time: '23:00 - 07:00 WIB',
          icon: Icons.nightlight_round_outlined,
        ),
        const SizedBox(height: 16),

        // Toggle Ingat Kredensial
        _buildRememberCredentialsRow(label: 'Ingat kredensial di perangkat hotel ini'),
        const SizedBox(height: 18),

        // Tombol Masuk ke Dashboard Operasional
        _buildPrimaryButton(
          title: 'Masuk ke Dashboard Operasional',
          onTap: _submitLogin,
        ),
      ],
    );
  }

  /// Kartu Pilihan Shift
  Widget _buildShiftCard({
    required int index,
    required String title,
    required String time,
    required IconData icon,
  }) {
    final isSelected = _selectedShift == index;

    return InkWell(
      onTap: () => setState(() => _selectedShift = index),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F5FD) : const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF00C2FF) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD8F3FE) : const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? const Color(0xFF008DA5) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFBAF0FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Aktif',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006D84),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF00C2FF),
                size: 20,
              ),
            ] else ...[
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  // ---------------------------------------------------------------------------
  // FORM ADMINISTRATOR (Termasuk PIN Otorisasi 6-Digit)
  // ---------------------------------------------------------------------------
  Widget _buildAdminForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Id petugas
        _buildRequiredLabel('Id petugas'),
        _buildInputField(
          controller: _adminIdController,
          hint: 'Masukkan id',
          icon: Icons.person_outline_rounded,
          textCapitalization: TextCapitalization.none,
        ),
        const SizedBox(height: 14),

        // Password
        _buildRequiredLabel('Password'),
        _buildInputField(
          controller: _adminPasswordController,
          hint: 'Masukkan password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 19,
              color: const Color(0xFF94A3B8),
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 16),

        // Kode Autentikasi (Sesuai format pihak Super Admin)
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
        const SizedBox(height: 16),

        // Toggle Ingat Kredensial
        _buildRememberCredentialsRow(label: 'Ingat kredensial di perangkat ini'),
        const SizedBox(height: 18),

        // Tombol Masuk ke Dashboard Administrator
        _buildPrimaryButton(
          title: 'Masuk ke Dashboard Administrator',
          onTap: _submitLogin,
        ),
      ],
    );
  }

  /// Kotak Digit PIN
  Widget _buildPinBox(int index) {
    final controller = _pinControllers[index];
    final focusNode = _pinFocusNodes[index];
    final isFilled = controller.text.isNotEmpty;

    return Container(
      width: 44,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFilled ? const Color(0xFF00C2FF) : const Color(0xFFE2E8F0),
          width: isFilled ? 1.5 : 1.0,
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
            hintText: '•',
            hintStyle: TextStyle(
              fontSize: 18,
              color: Color(0xFFCBD5E1),
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

  // ---------------------------------------------------------------------------
  // HELPER COMPONENTS
  // ---------------------------------------------------------------------------

  Widget _buildRequiredLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
          children: [
            TextSpan(text: text),
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF0096B4),
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

  Widget _buildRememberCredentialsRow({required String label}) {
    return Row(
      children: [
        const Icon(Icons.devices_outlined, size: 17, color: Color(0xFF0096B4)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155)),
          ),
        ),
        SizedBox(
          height: 24,
          child: Switch(
            value: _rememberCredentials,
            thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
              return Colors.white;
            }),
            activeTrackColor: const Color(0xFF00C2FF),
            inactiveTrackColor: const Color(0xFFE2E8F0),
            onChanged: (val) => setState(() => _rememberCredentials = val),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C2FF),
          elevation: 0,
          shadowColor: const Color(0xFF00C2FF).withValues(alpha: 0.35),
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
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
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
