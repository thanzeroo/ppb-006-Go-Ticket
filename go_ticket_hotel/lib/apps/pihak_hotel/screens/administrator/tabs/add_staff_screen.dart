import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../../../core/config/supabase_config.dart';
import '../../../../../../core/services/auth_service.dart';

/// Halaman Tambah Karyawan Baru untuk Administrator Hotel
/// Mendukung 3 Role:
/// 1. Staf (Front Office: Check-in, Check-out, Verifikasi Reservasi)
/// 2. Maintenance (Kebersihan Housekeeping & Laporan Kerusakan)
/// 3. Administrator (Kelola Akun, Keuangan, Master Kamar, dll.)
class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  static const Color _bg = Color(0xFFF6F8FB);
  static const Color _cardBorder = Color(0xFFE5E9F0);

  // Controllers (Semua field bersih tanpa data dummy)
  late TextEditingController _nameController;
  late TextEditingController _idStafController;
  late TextEditingController _passwordController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _nikController;
  late TextEditingController _shiftController;

  // 0: Staf (Front Office), 1: Maintenance, 2: Administrator
  int _selectedRole = 0;
  int _gender = 0; // 0: Laki-laki, 1: Perempuan
  String _selectedShift = 'Pagi';
  bool _obscurePassword = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Semua inputan diawali dalam kondisi kosong tanpa data dummy
    _nameController = TextEditingController();
    _idStafController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _nikController = TextEditingController();
    _shiftController = TextEditingController(text: 'Pagi');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idStafController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nikController.dispose();
    _shiftController.dispose();
    super.dispose();
  }

  String _generateStaffId(int roleIndex) {
    final rand = DateTime.now().millisecondsSinceEpoch % 900 + 100;
    switch (roleIndex) {
      case 0:
        return 'FO-2025-$rand';
      case 1:
        return 'MT-2025-$rand';
      case 2:
        return 'ADM-2025-$rand';
      default:
        return 'STF-2025-$rand';
    }
  }

  void _onRoleChanged(int newRole) {
    setState(() {
      _selectedRole = newRole;
    });
  }

  /// Submit Staff ke Supabase Database & Supabase Auth
  Future<void> _submitStaff() async {
    final name = _nameController.text.trim();
    final idStaf = _idStafController.text.trim();
    final password = _passwordController.text.trim();
    final email = _emailController.text.trim().toLowerCase();

    if (name.isEmpty) {
      _showError('Nama lengkap karyawan wajib diisi.');
      return;
    }
    if (idStaf.isEmpty) {
      _showError('ID Petugas (ID Staf) wajib diisi.');
      return;
    }
    if (password.length < 6) {
      _showError('Kata sandi minimal 6 karakter.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showError('Email login wajib valid (contoh: staf@hotel.com).');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = AuthService.instance.currentUser;
      final hotelId = user?.managedHotelId ?? '1';

      // 3 Role Database
      final roleMapping = ['front_office', 'maintenance', 'administrator'];
      final roleDb = roleMapping[_selectedRole.clamp(0, 2)];

      final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
          ? SupabaseConfig.supabaseServiceRoleKey
          : SupabaseConfig.activeApiKey;

      // 1. Jika memilih role Administrator, cek batas maksimal 3 akun administrator per hotel
      if (roleDb == 'administrator') {
        final checkUri = Uri.parse(
            '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableStafHotel}?id_penginapan=eq.$hotelId&role_jabatan=eq.administrator&select=id_staf');
        final checkResp = await http.get(
          checkUri,
          headers: {
            'apikey': serviceKey,
            'Authorization': 'Bearer $serviceKey',
          },
        );
        if (checkResp.statusCode == 200) {
          final List<dynamic> admins = jsonDecode(checkResp.body);
          if (admins.length >= 3) {
            setState(() => _isSaving = false);
            _showError(
                'Batas maksimal akun Administrator (3 akun) untuk hotel ini sudah tercapai.');
            return;
          }
        }
      }

      // 2. Daftarkan akun ke Supabase Auth via Admin REST API (Service Role Key)
      // Supaya staf dapat langsung login via auth.signInWithPassword
      try {
        final authUrl =
            Uri.parse('${SupabaseConfig.supabaseUrl}/auth/v1/admin/users');
        final userMetadata = <String, dynamic>{
          'full_name': name,
          'id_staf': idStaf,
          'role': roleDb,
        };

        await http.post(
          authUrl,
          headers: {
            'apikey': serviceKey,
            'Authorization': 'Bearer $serviceKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'password': password,
            'email_confirm': true,
            'user_metadata': userMetadata,
          }),
        );
      } catch (authErr) {
        debugPrint('⚠️ [AddStaff] Supabase Auth Admin Create Info: $authErr');
      }

      // 3. Simpan data staf ke tabel staf_hotel menggunakan REST API dengan Service Role Key
      // (Menghindari pelanggaran Row-Level Security / RLS policy 42501)
      final staffPayload = {
        'id_staf': idStaf,
        'id_penginapan': int.tryParse(hotelId) ?? 1,
        'nama_staf': name,
        'email': email,
        'password': password, // Mengisi kolom NOT NULL password
        'no_telepon': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'nik_staf': _nikController.text.trim().isEmpty
            ? null
            : _nikController.text.trim(),
        'role_jabatan': roleDb,
        'shift_tugas': _selectedShift,
        'status_karyawan': 'Aktif',
        'status_duty': 'Off',
      };

      final restUri = Uri.parse(
          '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableStafHotel}');
      final resp = await http.post(
        restUri,
        headers: {
          'apikey': serviceKey,
          'Authorization': 'Bearer $serviceKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=representation',
        },
        body: jsonEncode(staffPayload),
      );

      if (resp.statusCode != 200 && resp.statusCode != 201) {
        String errorDetail = resp.body;
        try {
          final errJson = jsonDecode(resp.body);
          if (errJson is Map && errJson.containsKey('message')) {
            errorDetail = errJson['message'];
            if (errJson.containsKey('details') && errJson['details'] != null) {
              errorDetail += ' (${errJson['details']})';
            }
          }
        } catch (_) {}
        throw Exception(errorDetail);
      }

      if (!mounted) return;

      // 4. Tampilkan Dialog Sukses Berisi Kredensial Login
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_rounded,
                  color: Color(0xFF10B981), size: 28),
              SizedBox(width: 10),
              Text('Akun Berhasil Dibuat!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Akun karyawan untuk $name telah tersimpan di database.',
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildKredensialRow('ID Petugas (Login):', idStaf),
                    const Divider(height: 14),
                    _buildKredensialRow('Kata Sandi:', password),
                    const Divider(height: 14),
                    _buildKredensialRow(
                        'Role:',
                        _selectedRole == 0
                            ? 'Staf (Front Office)'
                            : _selectedRole == 1
                                ? 'Maintenance'
                                : 'Administrator'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '💡 Karyawan dapat langsung masuk ke portal hotel dengan ID Petugas dan Kata Sandi di atas.',
                style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF0284C7),
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007A87),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('OK, Selesai'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showError('Gagal menyimpan ke database: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildKredensialRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B)),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A)),
        ),
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 26,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
            const SizedBox(width: 8),
            const Text(
              'Tambah Karyawan Hotel',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            // Top Badges
            _buildTopBadges(),
            const SizedBox(height: 16),

            // Card 1: Identitas Karyawan
            _buildIdentityCard(),
            const SizedBox(height: 16),

            // Card 2: 3 Role Pihak Hotel (Staf, Maintenance, Administrator)
            _buildRoleDepartmentCard(),
            const SizedBox(height: 16),

            // Card 3: Akun & Kredensial Login (ID Staf & Password)
            _buildCredentialsSecurityCard(),
            const SizedBox(height: 24),

            // Bottom Action Bar (Batal & Simpan)
            _buildBottomButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBadges() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.shield_outlined, size: 15, color: Color(0xFF0284C7)),
              SizedBox(width: 6),
              Text(
                'Sistem Manajemen Akun Staf Hotel',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0369A1)),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Otoritas Admin',
              style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Card 1: Data Identitas & Kontak
  Widget _buildIdentityCard() {
    return _buildSectionContainer(
      icon: Icons.badge_outlined,
      title: 'Data Identitas & Kontak',
      subtitle: 'Informasi personal karyawan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Lengkap
          _buildFieldLabel('Nama Lengkap Karyawan *'),
          _buildInput(
            controller: _nameController,
            hint: 'Masukkan nama',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 12),

          // ID Karyawan
          _buildFieldLabel('ID Karyawan (Opsional)'),
          _buildInput(
            controller: _nikController,
            hint: 'Masukkan id',
            prefixIcon: Icons.badge_outlined,
          ),
          const SizedBox(height: 12),

          // Nomor WhatsApp / Telepon
          _buildFieldLabel('Nomor WhatsApp / HP Aktif'),
          _buildInput(
            controller: _phoneController,
            hint: 'Masukkan nomor telepon',
            prefixIcon: Icons.phone_android_outlined,
          ),
          const SizedBox(height: 12),

          // Jenis Kelamin
          _buildFieldLabel('Jenis Kelamin'),
          Row(
            children: [
              Expanded(
                child: _buildGenderRadio(
                  index: 0,
                  label: 'Laki-laki',
                  icon: Icons.male,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildGenderRadio(
                  index: 1,
                  label: 'Perempuan',
                  icon: Icons.female,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderRadio({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSel = _gender == index;
    return GestureDetector(
      onTap: () => setState(() => _gender = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFFF0FDFE) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSel ? const Color(0xFF38BDF8) : const Color(0xFFE2E8F0),
            width: isSel ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSel ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: isSel ? const Color(0xFF007A87) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 16, color: const Color(0xFF475569)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A)),
            ),
          ],
        ),
      ),
    );
  }

  /// Card 2: 3 Roles Utama Pihak Hotel
  Widget _buildRoleDepartmentCard() {
    return _buildSectionContainer(
      icon: Icons.supervised_user_circle_outlined,
      title: 'Pilih Role Jabatan Karyawan',
      subtitle: 'Pihak hotel terbagi menjadi 3 roles operasional terpadu',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Role Staf (Front Office)
          _buildRoleOption(
            index: 0,
            title: 'Staf (Front Office)',
            dept: 'Departemen Front Desk & Resepsionis',
            desc:
                'Bertugas melakukan konfirmasi Check-In / Check-Out tamu, alokasi kamar fisik, dan verifikasi e-tiket booking.',
            icon: Icons.desk_rounded,
          ),
          const SizedBox(height: 10),

          // 2. Role Maintenance
          _buildRoleOption(
            index: 1,
            title: 'Maintenance',
            dept: 'Departemen Engineering & Housekeeping',
            desc:
                'Bertugas mengelola kebersihan kamar (Housekeeping), inspeksi sanitasi, dan menindaklanjuti laporan kerusakan fasilitas hotel.',
            icon: Icons.build_circle_outlined,
          ),
          const SizedBox(height: 10),

          // 3. Role Administrator (Maksimal 3 akun per hotel)
          _buildRoleOption(
            index: 2,
            title: 'Administrator',
            dept: 'Manajemen Hotel & Keuangan (Maks. 3 Akun)',
            desc:
                'Memiliki akses penuh mengelola akun staf, master kamar, tarif, dan laporan keuangan hotel.',
            icon: Icons.admin_panel_settings_outlined,
          ),
          const SizedBox(height: 16),

          // Shift Tugas Operasional (4 tombol horizontal sejajar)
          _buildFieldLabel('Shift Tugas Operasional'),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildShiftButton('Pagi', '07-15'),
              const SizedBox(width: 6),
              _buildShiftButton('Siang', '15-23'),
              const SizedBox(width: 6),
              _buildShiftButton('Malam', '23-07'),
              const SizedBox(width: 6),
              _buildShiftButton('Full Time', 'Full'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShiftButton(String label, String sub) {
    final isSel = _selectedShift == label;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedShift = label;
            _shiftController.text = label;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFFE0F4FB) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSel ? const Color(0xFF00C2FF) : const Color(0xFFE2E8F0),
              width: isSel ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isSel
                      ? const Color(0xFF007A87)
                      : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: isSel
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required int index,
    required String title,
    required String dept,
    required String desc,
    required IconData icon,
  }) {
    final isSel = _selectedRole == index;
    return GestureDetector(
      onTap: () => _onRoleChanged(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFFF0FDFE) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSel ? const Color(0xFF00C2FF) : const Color(0xFFE2E8F0),
            width: isSel ? 1.8 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 18,
                color:
                    isSel ? const Color(0xFF007A87) : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: const Color(0xFF007A87)),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dept,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(
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
      ),
    );
  }

  /// Card 4: Kredensial Akun Login (ID Petugas & Password)
  Widget _buildCredentialsSecurityCard() {
    return _buildSectionContainer(
      icon: Icons.lock_outline_rounded,
      title: 'Akun Login & Kredensial Masuk',
      subtitle:
          'Administrator membuatkan ID Petugas & Kata Sandi untuk staf/maintenance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID Petugas (ID Staf)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFieldLabel('ID Petugas (Digunakan Saat Login) *'),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _idStafController.text = _generateStaffId(_selectedRole);
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.auto_awesome,
                          size: 11, color: Color(0xFF0284C7)),
                      SizedBox(width: 4),
                      Text(
                        'Buat ID Otomatis',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildInput(
            controller: _idStafController,
            hint: 'Masukkan id petugas',
            prefixIcon: Icons.badge_outlined,
          ),
          const SizedBox(height: 4),
          const Text(
            'Format disarankan: FO-xxx (Staf FO), MT-xxx (Maintenance), ADM-xxx (Admin)',
            style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),

          // Kata Sandi (Password)
          _buildFieldLabel('Kata Sandi Login *'),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'Masukkan password',
              hintStyle:
                  const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              prefixIcon:
                  const Icon(Icons.lock_outline, color: Color(0xFF007A87)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 19,
                  color: const Color(0xFF94A3B8),
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: const Color(0xFFF1F5FD),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Kata sandi ini yang akan diketikkan karyawan saat masuk ke aplikasi hotel.',
            style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),

          // Email Login
          _buildFieldLabel('Email Akun (Sinkronisasi Auth) *'),
          _buildInput(
            controller: _emailController,
            hint: 'Masukkan email',
            prefixIcon: Icons.alternate_email,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155)),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF007A87), size: 19),
        filled: true,
        fillColor: const Color(0xFFF1F5FD),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F4FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF007A87), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _submitStaff,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C2FF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_add_alt_1_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Simpan & Daftarkan Karyawan',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
