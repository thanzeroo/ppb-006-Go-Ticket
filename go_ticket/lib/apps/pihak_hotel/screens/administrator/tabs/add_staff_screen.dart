import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../../../core/config/supabase_config.dart';
import '../../../../../../core/services/auth_service.dart';
import '../widgets/request_admin_email_sheet.dart';
import '../../../services/hotel_image_upload_service.dart';

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
  static const Color _teal = Color(0xFF005E73);
  static const Color _bg = Color(0xFFF6F8FB);
  static const Color _cardBorder = Color(0xFFE5E9F0);
  static const Color _cNormal = Color(0xFF00D1FF);

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
  bool _obscurePassword = true;
  bool _isSaving = false;

  // Foto Profil Karyawan (File lokal dari Kamera/Galeri atau URL Web)
  File? _selectedImageFile;
  String? _selectedAvatarUrl;

  final List<String> _sampleAvatars = [
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=300&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=300&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=300&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=300&auto=format&fit=crop',
  ];

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
    _shiftController = TextEditingController();
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
    if (newRole == 2) {
      showRequestAdminEmailModal(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Akun Administrator hanya dapat dibuat oleh Super Admin/Pihak Go Ticket. Silakan ajukan via formulir email.',
          ),
          backgroundColor: Color(0xFF007A87),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    setState(() {
      _selectedRole = newRole;
    });
  }

  /// Bottom Sheet Pemilih Foto: Kamera Langsung atau Galeri HP / File Komputer
  void _showPhotoPickerSheet() {
    final isDesktop =
        Platform.isLinux || Platform.isWindows || Platform.isMacOS;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilih Foto Profil Karyawan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  Text(
                    isDesktop
                        ? 'Pilih berkas foto dari laptop atau gunakan avatar sampel cepat.'
                        : 'Ambil foto langsung dengan kamera atau pilih dari penyimpanan ponsel.',
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),

                  // Pilihan 1: Kamera Langsung (Smartphone)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F4FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Color(0xFF007A87), size: 24),
                    ),
                    title: Row(
                      children: [
                        const Text(
                          'Ambil Foto dari Kamera',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (isDesktop) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Khusus HP',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFFB45309),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      isDesktop
                          ? 'Kamera native hanya aktif di perangkat ponsel Android/iOS'
                          : 'Otomatis membuka kamera untuk memotret',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    trailing: const Icon(Icons.chevron_right,
                        color: Color(0xFF94A3B8)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      if (isDesktop) {
                        _showError(
                            'Kamera perangkat langsung hanya didukung di smartphone. Membuka pemilih berkas foto laptop...');
                        await _pickImage(ImageSource.gallery);
                      } else {
                        await _pickImage(ImageSource.camera);
                      }
                    },
                  ),
                  const Divider(height: 14),

                  // Pilihan 2: Galeri / File Penyimpanan Komputer/HP
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.photo_library_rounded,
                          color: Color(0xFF7C3AED), size: 24),
                    ),
                    title: Text(
                      isDesktop
                          ? 'Pilih Foto dari Penyimpanan Laptop'
                          : 'Pilih dari Galeri / Penyimpanan HP',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      isDesktop
                          ? 'Membuka penjelajah berkas laptop untuk memilih gambar'
                          : 'Pilih foto dari berkas galeri penyimpanan ponsel',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    trailing: const Icon(Icons.chevron_right,
                        color: Color(0xFF94A3B8)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _pickImage(ImageSource.gallery);
                    },
                  ),
                  const Divider(height: 14),

                  // Pilihan 3: Avatar Sampel (Praktis untuk developer di laptop)
                  const Text(
                    'Atau Pilih Avatar Sampel Cepat (Cocok untuk Uji Coba):',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _sampleAvatars.map((url) {
                      final isSel = _selectedAvatarUrl == url &&
                          _selectedImageFile == null;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImageFile = null;
                            _selectedAvatarUrl = url;
                          });
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel
                                  ? const Color(0xFF00C2FF)
                                  : const Color(0xFFE2E8F0),
                              width: isSel ? 2.5 : 1,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(url),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  if (_selectedImageFile != null ||
                      _selectedAvatarUrl != null) ...[
                    const Divider(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: Color(0xFFDC2626), size: 24),
                      ),
                      title: const Text(
                        'Hapus Foto Terpilih',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _selectedImageFile = null;
                          _selectedAvatarUrl = null;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Eksekusi ambil gambar dari kamera atau galeri dengan penanganan error desktop yang aman
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _selectedAvatarUrl = null;
        });
      }
    } catch (e) {
      debugPrint('⚠️ [AddStaff] Error picking image: $e');
      final errStr = e.toString();
      if (errStr.contains('MissingPluginException') ||
          errStr.contains('channel')) {
        _showError(
            'Plugin kamera memerlukan restart penuh aplikasi (flutter run), dan fitur kamera langsung hanya didukung di smartphone.');
        // Fallback coba buka file galeri laptop
        try {
          final picker = ImagePicker();
          final XFile? picked =
              await picker.pickImage(source: ImageSource.gallery);
          if (picked != null) {
            setState(() {
              _selectedImageFile = File(picked.path);
              _selectedAvatarUrl = null;
            });
          }
        } catch (_) {}
      } else {
        _showError('Gagal memilih foto: $e');
      }
    }
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

      // 1. Upload Foto Profil jika Administrator memilih foto dari kamera/galeri
      String? photoUrl = _selectedAvatarUrl;
      if (_selectedImageFile != null && _selectedImageFile!.existsSync()) {
        try {
          final cleanId = idStaf.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
          final uploaded = await HotelImageUploadService.instance.uploadFile(
            _selectedImageFile!,
            prefix: 'staf_$cleanId',
          );
          if (uploaded != null && uploaded.isNotEmpty) {
            photoUrl = uploaded;
            debugPrint('✅ [AddStaff] Foto profil berhasil diunggah: $photoUrl');
          }
        } catch (uploadErr) {
          debugPrint('⚠️ [AddStaff] Upload foto gagal: $uploadErr');
        }
      }

      // 2. Daftarkan akun ke Supabase Auth via Admin REST API (Service Role Key)
      // Supaya staf dapat langsung login via auth.signInWithPassword
      try {
        final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
            ? SupabaseConfig.supabaseServiceRoleKey
            : SupabaseConfig.activeApiKey;

        final authUrl =
            Uri.parse('${SupabaseConfig.supabaseUrl}/auth/v1/admin/users');
        final userMetadata = <String, dynamic>{
          'full_name': name,
          'id_staf': idStaf,
          'role': roleDb,
        };
        if (photoUrl != null) {
          userMetadata['avatar_url'] = photoUrl;
        }

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
        'shift_tugas': _shiftController.text.trim().isEmpty
            ? null
            : _shiftController.text.trim(),
        'status_karyawan': 'Aktif',
        'status_duty': 'Off',
      };

      final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
          ? SupabaseConfig.supabaseServiceRoleKey
          : SupabaseConfig.activeApiKey;

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

            // Card 1: Foto Profil & Identitas Karyawan (Kamera & Galeri HP)
            _buildIdentityCard(),
            const SizedBox(height: 16),

            // Card 2: 3 Role Pihak Hotel (Staf, Maintenance, Administrator)
            _buildRoleDepartmentCard(),
            const SizedBox(height: 16),

            // Card 3: Hak Akses Otomatis Sesuai Role & Portal
            _buildAccessModuleCard(),
            const SizedBox(height: 16),

            // Card 4: Akun & Kredensial Login (ID Staf & Password)
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

  /// Card 1: Data Identitas & Foto Profil (Pilih Kamera / Galeri HP)
  Widget _buildIdentityCard() {
    return _buildSectionContainer(
      icon: Icons.badge_outlined,
      title: 'Data Identitas & Kontak',
      subtitle: 'Informasi personal dan foto profil resmi karyawan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Foto Profil
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showPhotoPickerSheet,
                  child: Stack(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF1F5FD),
                          border: Border.all(color: _cNormal, width: 2),
                        ),
                        child: _selectedImageFile != null
                            ? ClipOval(
                                child: Image.file(
                                  _selectedImageFile!,
                                  fit: BoxFit.cover,
                                  width: 64,
                                  height: 64,
                                ),
                              )
                            : _selectedAvatarUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      _selectedAvatarUrl!,
                                      fit: BoxFit.cover,
                                      width: 64,
                                      height: 64,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Center(
                                        child: Icon(
                                          Icons.person_outline_rounded,
                                          size: 34,
                                          color: Color(0xFF005E73),
                                        ),
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      size: 34,
                                      color: Color(0xFF005E73),
                                    ),
                                  ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: _teal,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 13, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Foto Profil Karyawan',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedImageFile != null
                            ? 'Foto dari file perangkat dipilih'
                            : _selectedAvatarUrl != null
                                ? 'Foto avatar profil dipilih'
                                : 'Belum ada foto yang dipilih',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: (_selectedImageFile != null ||
                                  _selectedAvatarUrl != null)
                              ? const Color(0xFF059669)
                              : const Color(0xFF64748B),
                          fontWeight: (_selectedImageFile != null ||
                                  _selectedAvatarUrl != null)
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _showPhotoPickerSheet,
                            icon: const Icon(Icons.add_a_photo_outlined,
                                size: 13),
                            label: Text((_selectedImageFile != null ||
                                    _selectedAvatarUrl != null)
                                ? 'Ubah Foto'
                                : 'Pilih Foto'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007A87),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              minimumSize: const Size(0, 28),
                              textStyle: const TextStyle(
                                  fontSize: 10.5, fontWeight: FontWeight.w700),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          if (_selectedImageFile != null ||
                              _selectedAvatarUrl != null) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => setState(() {
                                _selectedImageFile = null;
                                _selectedAvatarUrl = null;
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Hapus',
                                  style: TextStyle(
                                      fontSize: 10.5,
                                      color: Color(0xFFDC2626),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Nama Lengkap (Kosong Bersih)
          _buildFieldLabel('Nama Lengkap Karyawan *'),
          _buildInput(
            controller: _nameController,
            hint: 'Contoh: Ahmad Fauzi / Dewi Ayu',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 12),

          // NIK
          _buildFieldLabel('NIK KTP Karyawan'),
          _buildInput(
            controller: _nikController,
            hint: '16 Digit NIK Karyawan',
            prefixIcon: Icons.credit_card_outlined,
          ),
          const SizedBox(height: 12),

          // Nomor WhatsApp / Telepon
          _buildFieldLabel('Nomor WhatsApp / HP Aktif'),
          _buildInput(
            controller: _phoneController,
            hint: 'Contoh: 081234567890',
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
            badge: 'Portal FO',
            badgeBg: const Color(0xFFE0F4FB),
            badgeFg: const Color(0xFF0284C7),
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
            badge: 'Portal Maintenance',
            badgeBg: const Color(0xFFEDE9FE),
            badgeFg: const Color(0xFF7C3AED),
            desc:
                'Bertugas mengelola kebersihan kamar (Housekeeping), inspeksi sanitasi, dan menindaklanjuti laporan kerusakan fasilitas hotel.',
            icon: Icons.build_circle_outlined,
          ),
          const SizedBox(height: 10),

          // 3. Role Administrator (Hanya via Go Ticket)
          _buildRoleOption(
            index: 2,
            title: 'Administrator',
            dept: 'Wewenang Pihak Go Ticket',
            badge: 'Via Email Go Ticket',
            badgeBg: const Color(0xFFFEF3C7),
            badgeFg: const Color(0xFFB45309),
            desc:
                'Hanya Super Admin / Pihak Go Ticket yang dapat membuatkan akun Administrator. Klik untuk mengajukan via email.',
            icon: Icons.admin_panel_settings_outlined,
          ),
          const SizedBox(height: 16),

          // Shift Tugas
          _buildFieldLabel('Shift Tugas Operasional'),
          _buildInput(
            controller: _shiftController,
            hint: 'Contoh: Shift Pagi / Siang / Malam',
            prefixIcon: Icons.access_time,
          ),
          const SizedBox(height: 8),

          // Quick Chips Pilihan Shift
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildShiftPresetChip('Shift Pagi (07:00 – 15:00 WIB)'),
              _buildShiftPresetChip('Shift Siang (15:00 – 23:00 WIB)'),
              _buildShiftPresetChip('Shift Malam (23:00 – 07:00 WIB)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShiftPresetChip(String shiftText) {
    return InkWell(
      onTap: () {
        setState(() {
          _shiftController.text = shiftText;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Text(
          shiftText,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF334155),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required int index,
    required String title,
    required String dept,
    required String badge,
    required Color badgeBg,
    required Color badgeFg,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: badgeFg,
                          ),
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

  /// Card 3: Hak Akses Otomatis Sesuai Role
  Widget _buildAccessModuleCard() {
    final roleName = _selectedRole == 0
        ? 'Staf (Front Office)'
        : _selectedRole == 1
            ? 'Maintenance'
            : 'Administrator';

    return _buildSectionContainer(
      icon: Icons.shield_outlined,
      title: 'Hak Akses & Modul Otomatis',
      subtitle: 'Hak akses disesuaikan secara otomatis sesuai portal $roleName',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome,
                    size: 16, color: Color(0xFF0284C7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Modul aktif otomatis disesuaikan dengan Dashboard $roleName',
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF0369A1),
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tampilkan hak akses khusus role yang dipilih
          if (_selectedRole == 0) ...[
            _buildAutoAccessItem(
              icon: Icons.confirmation_number_outlined,
              title: 'Verifikasi & Konfirmasi Booking Tamu',
              desc:
                  'Meninjau rincian reservasi, verifikasi pembayaran, & penerbitan e-tiket.',
            ),
            _buildAutoAccessItem(
              icon: Icons.meeting_room_outlined,
              title: 'Eksekusi Check-In & Alokasi Kunci RFID',
              desc: 'Pencarian kode booking dan registrasi kedatangan tamu.',
            ),
            _buildAutoAccessItem(
              icon: Icons.door_sliding_outlined,
              title: 'Eksekusi Check-Out & Turnover Kamar',
              desc:
                  'Proses kepulangan tamu, pengembalian deposit, & update kamar kotor.',
            ),
            _buildAutoAccessItem(
              icon: Icons.dashboard_outlined,
              title: 'Ringkasan Okupansi Kamar Harian',
              desc: 'Monitor rasio kamar terisi dan ketersediaan real-time.',
            ),
          ] else if (_selectedRole == 1) ...[
            _buildAutoAccessItem(
              icon: Icons.cleaning_services_outlined,
              title: 'Papan Kebersihan Kamar & Housekeeping',
              desc:
                  'Pembaruan status kamar Bersih, Kotor, Sedang Dibersihkan, & Inspeksi.',
            ),
            _buildAutoAccessItem(
              icon: Icons.checklist_rtl_rounded,
              title: 'Checklist Sanitasi & Standar Amenitas',
              desc:
                  'Pemeriksaan sprei, linen, handuk, perlengkapan mandi, & minibar.',
            ),
            _buildAutoAccessItem(
              icon: Icons.build_outlined,
              title: 'Pencatatan & Laporan Kerusakan Fasilitas',
              desc:
                  'Input kendala unit AC, kelistrikan, pipa bocor, & perbaikan inventaris.',
            ),
            _buildAutoAccessItem(
              icon: Icons.history_toggle_off_rounded,
              title: 'Log Riwayat Perbaikan & Maintenance',
              desc:
                  'Dokumentasi tindak lanjut penugasan teknisi dan status perbaikan.',
            ),
          ] else ...[
            _buildAutoAccessItem(
              icon: Icons.manage_accounts_outlined,
              title: 'Pengelolaan Akun Karyawan & Staf',
              desc:
                  'Pendaftaran akun Staf Front Office, Maintenance, dan pengaturan shift.',
            ),
            _buildAutoAccessItem(
              icon: Icons.hotel_outlined,
              title: 'Manajemen Kamar, Tarif & Fasilitas',
              desc:
                  'Pengaturan tipe kamar, harga sewa per malam, dan inventaris kamar.',
            ),
            _buildAutoAccessItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Laporan Keuangan & Penarikan Dana',
              desc:
                  'Monitor saldo pendapatan hotel, buku kas transaksi, & mutasi rekening.',
            ),
            _buildAutoAccessItem(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Kontrol Penuh Sistem & Akses Hotel',
              desc:
                  'Otoritas tertinggi administrasi operasional properti hotel mitra.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAutoAccessItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F4FB),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF007A87)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const Icon(Icons.check_circle,
                        size: 14, color: Color(0xFF10B981)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style:
                      const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
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
            hint: 'Ketik manual atau klik Buat ID Otomatis',
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
              hintText: 'Minimal 6 karakter kata sandi baru',
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
            hint: 'Contoh: staf.hotel@gmail.com',
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
