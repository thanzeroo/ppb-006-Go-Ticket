import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../../../core/config/supabase_config.dart';
import '../../../../../../core/models/hotel_admin_model.dart';

/// Halaman Edit Data Karyawan & Kelola Hak Akses
/// Administrator dapat mengubah nama, kontak, shift tugas, role jabatan (3 role),
/// status keaktifan, serta menghapus akun karyawan secara permanen.
class EditStaffScreen extends StatefulWidget {
  final String staffName;
  final String staffId;
  final String initialRole;
  final StaffData? staff;

  const EditStaffScreen({
    super.key,
    this.staffName = 'Karyawan Hotel',
    this.staffId = 'STF-001',
    this.initialRole = 'Staf',
    this.staff,
  });

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  static const Color _teal = Color(0xFF005E73);
  static const Color _bg = Color(0xFFF6F8FB);
  static const Color _cardBorder = Color(0xFFE5E9F0);
  static const Color _cNormal = Color(0xFF00D1FF);

  late TextEditingController _nameController;
  late TextEditingController _nikController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _shiftController;

  // 0: Staf (Front Office), 1: Maintenance, 2: Administrator
  int _selectedRole = 0;
  bool _isDuty = false;
  String _statusKaryawan = 'Aktif';
  bool _isSaving = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final s = widget.staff;

    _nameController =
        TextEditingController(text: s?.name ?? widget.staffName);
    _nikController = TextEditingController(text: s?.nik ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');
    _phoneController = TextEditingController(text: s?.wa ?? '');
    _shiftController = TextEditingController(
        text: s?.shift ?? 'Shift Pagi (07:00 – 15:00 WIB)');

    // Role mapping
    final roleStr = (s?.roleKey ?? s?.role ?? widget.initialRole).toLowerCase();
    if (roleStr.contains('admin')) {
      _selectedRole = 2;
    } else if (roleStr.contains('maint') || roleStr.contains('housekeeping')) {
      _selectedRole = 1;
    } else {
      _selectedRole = 0;
    }

    _isDuty = s?.statusLabel == 'On-Duty';
    _statusKaryawan =
        (s?.statusLabel == 'Non-aktif' || s?.status == 'Non-aktif')
            ? 'Non-aktif'
            : 'Aktif';

    // Fetch live data dari database jika ada informasi yang belum lengkap
    _loadLiveStaffData();
  }

  Future<void> _loadLiveStaffData() async {
    setState(() => _isLoading = true);
    try {
      final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
          ? SupabaseConfig.supabaseServiceRoleKey
          : SupabaseConfig.activeApiKey;

      final uri = Uri.parse(
          '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableStafHotel}?id_staf=eq.${widget.staffId}&select=*');
      final resp = await http.get(uri, headers: {
        'apikey': serviceKey,
        'Authorization': 'Bearer $serviceKey',
      });

      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List<dynamic>;
        if (list.isNotEmpty && mounted) {
          final data = list.first as Map<String, dynamic>;
          setState(() {
            _nameController.text = data['nama_staf'] ?? _nameController.text;
            _nikController.text = data['nik_staf'] ?? _nikController.text;
            _emailController.text = data['email'] ?? _emailController.text;
            _phoneController.text =
                data['no_telepon'] ?? _phoneController.text;
            _shiftController.text =
                data['shift_tugas'] ?? _shiftController.text;

            final r = (data['role_jabatan'] ?? '').toString().toLowerCase();
            if (r.contains('admin')) {
              _selectedRole = 2;
            } else if (r.contains('maint')) {
              _selectedRole = 1;
            } else {
              _selectedRole = 0;
            }

            _isDuty = (data['status_duty'] ?? '').toString().toLowerCase() ==
                'on';
            _statusKaryawan = data['status_karyawan'] ?? 'Aktif';
          });
        }
      }
    } catch (e) {
      debugPrint('⚠️ [EditStaff] Error loading live staff data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _shiftController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdateStaff() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final nik = _nikController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      _showError('Nama lengkap karyawan wajib diisi.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final roleMapping = ['front_office', 'maintenance', 'administrator'];
      final roleDb = roleMapping[_selectedRole.clamp(0, 2)];

      final payload = {
        'nama_staf': name,
        'no_telepon': phone.isEmpty ? null : phone,
        'nik_staf': nik.isEmpty ? null : nik,
        'email': email.isEmpty ? null : email,
        'role_jabatan': roleDb,
        'shift_tugas': _shiftController.text.trim().isEmpty
            ? null
            : _shiftController.text.trim(),
        'status_duty': _isDuty ? 'On' : 'Off',
        'status_karyawan': _statusKaryawan,
      };

      final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
          ? SupabaseConfig.supabaseServiceRoleKey
          : SupabaseConfig.activeApiKey;

      final uri = Uri.parse(
          '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableStafHotel}?id_staf=eq.${widget.staffId}');
      final resp = await http.patch(
        uri,
        headers: {
          'apikey': serviceKey,
          'Authorization': 'Bearer $serviceKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=representation',
        },
        body: jsonEncode(payload),
      );

      if (resp.statusCode != 200 && resp.statusCode != 204) {
        throw Exception('Gagal menyimpan ke database: ${resp.body}');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perubahan data karyawan berhasil disimpan!'),
          backgroundColor: _teal,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showError('Gagal menyimpan perubahan: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDeleteStaff() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded,
                color: Color(0xFFDC2626), size: 26),
            SizedBox(width: 8),
            Text('Hapus Akun Karyawan?',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus akun ${_nameController.text} (${widget.staffId}) secara permanen? Data dan kredensial login akan terhapus.',
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus Akun',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
          ? SupabaseConfig.supabaseServiceRoleKey
          : SupabaseConfig.activeApiKey;

      final uri = Uri.parse(
          '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableStafHotel}?id_staf=eq.${widget.staffId}');
      final resp = await http.delete(uri, headers: {
        'apikey': serviceKey,
        'Authorization': 'Bearer $serviceKey',
      });

      if (resp.statusCode != 200 && resp.statusCode != 204) {
        throw Exception('Gagal menghapus: ${resp.body}');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun karyawan berhasil dihapus permanen.'),
          backgroundColor: _teal,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showError('Gagal menghapus karyawan: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
              'Kelola Akses & Data Karyawan',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _teal))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  // Header Card Ringkasan Karyawan
                  _buildProfileSummaryCard(),
                  const SizedBox(height: 16),

                  // Card 1: Data Identitas & Kontak
                  _buildProfileInfoCard(),
                  const SizedBox(height: 16),

                  // Card 2: Role Jabatan (3 Roles Hotel)
                  _buildRoleCard(),
                  const SizedBox(height: 16),

                  // Card 3: Penjadwalan Shift & Duty
                  _buildShiftCard(),
                  const SizedBox(height: 16),

                  // Card 4: Status Keaktifan Akun
                  _buildStatusCard(),
                  const SizedBox(height: 16),

                  // Card 5: Area Hapus Akun Karyawan
                  _buildDeleteCard(),
                  const SizedBox(height: 24),

                  // Tombol Aksi Bawah: Batal & Simpan Perubahan
                  _buildBottomButtons(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSummaryCard() {
    final roleNames = ['Staf (Front Office)', 'Maintenance', 'Administrator'];
    final roleColors = [
      const Color(0xFF0284C7),
      const Color(0xFF7C3AED),
      const Color(0xFF15803D),
    ];
    final roleBgs = [
      const Color(0xFFE0F4FB),
      const Color(0xFFEDE9FE),
      const Color(0xFFDCFCE7),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFE0F4FB),
            child: Text(
              _nameController.text.isNotEmpty
                  ? _nameController.text[0].toUpperCase()
                  : 'S',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _teal),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.staffId,
                        style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleBgs[_selectedRole.clamp(0, 2)],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        roleNames[_selectedRole.clamp(0, 2)],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: roleColors[_selectedRole.clamp(0, 2)],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _nameController.text.isEmpty
                      ? 'Nama Karyawan'
                      : _nameController.text,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _isDuty ? Icons.circle : Icons.circle_outlined,
                      size: 8,
                      color: _isDuty
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isDuty
                          ? 'Aktif Bertugas (On-Duty)'
                          : 'Sedang Libur (Off-Duty)',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: _isDuty
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    return _buildSectionContainer(
      icon: Icons.person_outline,
      title: 'Informasi Karyawan & Kontak',
      subtitle: 'Data personal dan kredensial komunikasi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Nama Lengkap Karyawan *'),
          _buildInput(controller: _nameController, hint: 'Masukkan nama'),
          const SizedBox(height: 12),
          _buildFieldLabel('ID Karyawan (Opsional)'),
          _buildInput(controller: _nikController, hint: 'Masukkan id'),
          const SizedBox(height: 12),
          _buildFieldLabel('Nomor WhatsApp / HP Aktif'),
          _buildInput(controller: _phoneController, hint: 'Masukkan nomor telepon'),
          const SizedBox(height: 12),
          _buildFieldLabel('Email Akun Login'),
          _buildInput(
              controller: _emailController, hint: 'Masukkan email'),
        ],
      ),
    );
  }

  Widget _buildRoleCard() {
    return _buildSectionContainer(
      icon: Icons.supervised_user_circle_outlined,
      title: 'Role Jabatan & Hak Akses',
      subtitle: 'Tentukan peran operasional di ekosistem pihak hotel',
      child: Column(
        children: [
          _buildRoleRadio(
            index: 0,
            title: 'Staf (Front Office)',
            dept: 'Front Desk & Resepsionis',
            desc:
                'Menangani konfirmasi Check-In / Check-Out, verifikasi reservasi booking, dan alokasi kamar.',
          ),
          const SizedBox(height: 8),
          _buildRoleRadio(
            index: 1,
            title: 'Maintenance',
            dept: 'Engineering & Housekeeping',
            desc:
                'Mengelola status kebersihan kamar, inspeksi sanitasi, dan menindaklanjuti laporan kerusakan fasilitas.',
          ),
          const SizedBox(height: 8),
          _buildRoleRadio(
            index: 2,
            title: 'Administrator',
            dept: 'Manajemen Hotel & Keuangan',
            desc:
                'Akses penuh kelola staf, master kamar & tarif, laporan keuangan hotel, serta audit operasional.',
          ),
        ],
      ),
    );
  }

  Widget _buildRoleRadio({
    required int index,
    required String title,
    required String dept,
    required String desc,
  }) {
    final isSel = _selectedRole == index;
    return InkWell(
      onTap: () => setState(() => _selectedRole = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFFF0FDFE) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSel ? const Color(0xFF00C2FF) : const Color(0xFFE2E8F0),
            width: isSel ? 1.6 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 17,
                color: isSel ? _teal : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A)),
                  ),
                  Text(
                    dept,
                    style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0284C7)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF64748B), height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftCard() {
    return _buildSectionContainer(
      icon: Icons.access_time_rounded,
      title: 'Shift Tugas & Jadwal Kerja',
      subtitle: 'Alokasi shift operasional karyawan yang terdaftar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Shift Tugas Operasional'),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildShiftHorizButton('Pagi', '07-15'),
              const SizedBox(width: 6),
              _buildShiftHorizButton('Siang', '15-23'),
              const SizedBox(width: 6),
              _buildShiftHorizButton('Malam', '23-07'),
              const SizedBox(width: 6),
              _buildShiftHorizButton('Full Time', 'Full'),
            ],
          ),
          const SizedBox(height: 14),

          // Switch On-Duty
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(
                  _isDuty
                      ? Icons.check_circle_rounded
                      : Icons.pause_circle_outline,
                  color: _isDuty
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF64748B),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isDuty
                            ? 'Status: Sedang Bertugas (On-Duty)'
                            : 'Status: Sedang Istirahat / Libur (Off-Duty)',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A)),
                      ),
                      const Text(
                        'Indikator tampil aktif di dasbor operasional hotel',
                        style:
                            TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isDuty,
                  activeThumbColor: _cNormal,
                  onChanged: (val) => setState(() => _isDuty = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftHorizButton(String label, String sub) {
    final current = _shiftController.text.toLowerCase();
    final isSel = current == label.toLowerCase() ||
        current.contains(label.toLowerCase());
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _shiftController.text = label),
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

  Widget _buildStatusCard() {
    return _buildSectionContainer(
      icon: Icons.toggle_on_outlined,
      title: 'Status Akun Karyawan',
      subtitle: 'Kendali keaktifan akses login staf ke aplikasi hotel',
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _statusKaryawan = 'Aktif'),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _statusKaryawan == 'Aktif'
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _statusKaryawan == 'Aktif'
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFE2E8F0),
                    width: _statusKaryawan == 'Aktif' ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_circle,
                        size: 16, color: Color(0xFF16A34A)),
                    SizedBox(width: 6),
                    Text(
                      'Akun Aktif',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _statusKaryawan = 'Non-aktif'),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _statusKaryawan == 'Non-aktif'
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _statusKaryawan == 'Non-aktif'
                        ? const Color(0xFFDC2626)
                        : const Color(0xFFE2E8F0),
                    width: _statusKaryawan == 'Non-aktif' ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.block, size: 16, color: Color(0xFFDC2626)),
                    SizedBox(width: 6),
                    Text(
                      'Non-aktifkan',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFDC2626), size: 20),
              SizedBox(width: 8),
              Text(
                'Tindakan Kritis / Hapus Akun',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF991B1B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Menghapus akun akan mencabut seluruh hak akses karyawan ini dan menghapus profilnya secara permanen dari database hotel.',
            style: TextStyle(fontSize: 11, color: Color(0xFFB91C1C), height: 1.3),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _confirmDeleteStaff,
              icon: const Icon(Icons.delete_forever_rounded, size: 18),
              label: const Text('Hapus Akun Karyawan Ini',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Batal',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569))),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _submitUpdateStaff,
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
                  : const Text(
                      'Simpan Perubahan',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155)),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
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
            blurRadius: 8,
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
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F4FB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF007A87), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A)),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 10.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
