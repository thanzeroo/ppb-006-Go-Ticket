import 'package:flutter/material.dart';

import 'package:go_ticket/core/widgets/app_pagination_bar.dart';
import '../../../../../core/models/hotel_model.dart';
import '../../../../../core/models/user_model.dart';
import '../../../../../core/services/hotel_service.dart';
import '../../../../../core/services/super_admin_service.dart';

/// Tab 4: Direktori Pengguna & Staf Super Admin (100% Dinamis dari Database)
class UserTab extends StatefulWidget {
  const UserTab({super.key});

  @override
  State<UserTab> createState() => _UserTabState();
}

class _UserTabState extends State<UserTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRoleFilter = 'Semua'; // 'Semua', 'Tamu', 'Staf Hotel'
  String _selectedStatusFilter = 'Semua'; // 'Semua', 'Aktif', 'Tersuspend'

  List<UserModel> _users = [];
  List<HotelModel> _hotels = [];
  Map<String, HotelModel> _hotelMap = {};
  bool _isLoading = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        SuperAdminService.instance.getAllUsers(),
        HotelService.instance.getHotels(),
      ]);
      final list = results[0] as List<UserModel>;
      final hotelList = results[1] as List<HotelModel>;
      final map = {for (final h in hotelList) h.id: h};

      if (mounted) {
        setState(() {
          _users = list;
          _hotels = hotelList;
          _hotelMap = map;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _users = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> get _filteredUsers {
    return _users.where((u) {
      // 1. Search Query Filter
      final q = _searchQuery.trim().toLowerCase();
      if (q.isNotEmpty) {
        final matches = u.fullName.toLowerCase().contains(q) ||
            (u.email?.toLowerCase().contains(q) ?? false) ||
            (u.phoneNumber?.toLowerCase().contains(q) ?? false);
        if (!matches) return false;
      }

      // 2. Role Filter
      if (_selectedRoleFilter == 'Tamu') {
        if (u.role != UserRole.customer) return false;
      } else if (_selectedRoleFilter == 'Staf Hotel') {
        if (u.role == UserRole.customer) return false;
      }

      // 3. Status Filter
      if (_selectedStatusFilter == 'Aktif') {
        if (!u.isActive) return false;
      } else if (_selectedStatusFilter == 'Tersuspend') {
        if (u.isActive) return false;
      }

      return true;
    }).toList();
  }

  Future<void> _toggleStatus(UserModel u) async {
    final newStatus = !u.isActive;
    final ok =
        await SuperAdminService.instance.toggleUserStatus(u.id, newStatus);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Status ${u.fullName} diubah menjadi ${newStatus ? "Aktif" : "Non-aktif / Tersuspend"}'),
          backgroundColor: newStatus ? const Color(0xFF16A34A) : Colors.orange,
        ),
      );
      _loadUsers();
    }
  }

  Future<void> _deleteUser(UserModel u) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Akun Pengguna',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Apakah Anda yakin ingin menghapus akun "${u.fullName}" (${u.email ?? u.phoneNumber ?? '-'})? Data yang dihapus tidak dapat dipulihkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await SuperAdminService.instance.deleteUser(u.id);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Akun ${u.fullName} berhasil dihapus dari database'),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
      _loadUsers();
    }
  }

  void _showEditUserModal(UserModel u) {
    final nameCtrl = TextEditingController(text: u.fullName);
    final emailCtrl = TextEditingController(text: u.email ?? '');
    final phoneCtrl = TextEditingController(text: u.phoneNumber ?? '');
    bool isActive = u.isActive;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Akun Pengguna',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Alamat Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor Telepon',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status Akun Aktif',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Switch(
                      value: isActive,
                      activeColor: const Color(0xFF00C2FF),
                      onChanged: (val) {
                        setModalState(() => isActive = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00758F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final ok = await SuperAdminService.instance.updateUser(
                        userId: u.id,
                        fullName: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        phoneNumber: phoneCtrl.text.trim(),
                        status: isActive ? 'aktif' : 'tersuspend',
                      );
                      if (mounted) {
                        Navigator.pop(ctx);
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data pengguna berhasil diperbarui!'),
                              backgroundColor: Color(0xFF16A34A),
                            ),
                          );
                          _loadUsers();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal memperbarui data pengguna'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Simpan Perubahan',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
        },
      ),
    );
  }

  void _showAddUserModal() {
    int accountType = 0; // 0 = Administrator Hotel, 1 = Tamu
    String? selectedHotelId = _hotels.isNotEmpty ? _hotels.first.id : null;
    String selectedRoleJabatan = 'administrator'; // administrator, front_office, maintenance
    String selectedShift = 'General';
    bool obscurePassword = true;

    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final nikCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tambah Pengguna Baru',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Segmented Switcher: Administrator Hotel vs Tamu
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setModalState(() => accountType = 0),
                            borderRadius: BorderRadius.circular(9),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: accountType == 0 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: accountType == 0
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.06),
                                          blurRadius: 4,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'Administrator / Staf Hotel',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: accountType == 0 ? FontWeight.w800 : FontWeight.w600,
                                  color: accountType == 0 ? const Color(0xFF00758F) : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setModalState(() => accountType = 1),
                            borderRadius: BorderRadius.circular(9),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: accountType == 1 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: accountType == 1
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.06),
                                          blurRadius: 4,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'Tamu / Pelanggan',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: accountType == 1 ? FontWeight.w800 : FontWeight.w600,
                                  color: accountType == 1 ? const Color(0xFF00758F) : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (accountType == 0) ...[
                    // Info Banner
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline, size: 16, color: Color(0xFF16A34A)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Akun Administrator Hotel dibuat agar mitra dapat mengelola properti, kamar, dan menambahkan karyawan hotel.',
                              style: TextStyle(fontSize: 10.5, color: Color(0xFF15803D)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Pilih Hotel
                    if (_hotels.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: const Text(
                          'Belum ada data mitra penginapan/hotel di database. Silakan buat mitra hotel terlebih dahulu di tab Kelola Hotel.',
                          style: TextStyle(fontSize: 11, color: Color(0xFFDC2626)),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: selectedHotelId,
                        decoration: InputDecoration(
                          labelText: 'Mitra Penginapan / Hotel *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        items: _hotels.map((h) {
                          return DropdownMenuItem<String>(
                            value: h.id,
                            child: Text(
                              '${h.name} (${h.city})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedHotelId = val);
                        },
                      ),
                    const SizedBox(height: 12),

                    // Role / Jabatan
                    DropdownButtonFormField<String>(
                      value: selectedRoleJabatan,
                      decoration: InputDecoration(
                        labelText: 'Jabatan / Posisi *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'administrator',
                          child: Text('Administrator Hotel (Owner / General Manager)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        DropdownMenuItem(
                          value: 'front_office',
                          child: Text('Front Office (Resepsionis / Kasir)',
                              style: TextStyle(fontSize: 12)),
                        ),
                        DropdownMenuItem(
                          value: 'maintenance',
                          child: Text('Maintenance (Housekeeping / Teknisi)',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedRoleJabatan = val);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Nama Lengkap
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Email
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Alamat Email Login *',
                      hintText: accountType == 0 ? 'admin@hotel.com' : 'user@gmail.com',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Password
                  TextField(
                    controller: passCtrl,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi / Password *',
                      hintText: 'Minimal 6 karakter',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                        ),
                        onPressed: () => setModalState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // No Telepon
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor WhatsApp / HP',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),

                  if (accountType == 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nikCtrl,
                            decoration: InputDecoration(
                              labelText: 'NIK Karyawan (Opsional)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedShift,
                            decoration: InputDecoration(
                              labelText: 'Shift Tugas',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'General', child: Text('General (Normal)', style: TextStyle(fontSize: 11.5))),
                              DropdownMenuItem(value: 'Pagi', child: Text('Pagi (07-15)', style: TextStyle(fontSize: 11.5))),
                              DropdownMenuItem(value: 'Siang', child: Text('Siang (15-23)', style: TextStyle(fontSize: 11.5))),
                              DropdownMenuItem(value: 'Malam', child: Text('Malam (23-07)', style: TextStyle(fontSize: 11.5))),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => selectedShift = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00758F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final email = emailCtrl.text.trim();
                        final pass = passCtrl.text.trim();

                        if (name.isEmpty || email.isEmpty || pass.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nama lengkap, email login, dan kata sandi wajib diisi'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (pass.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kata sandi minimal 6 karakter'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final scaffold = ScaffoldMessenger.of(context);
                        final nav = Navigator.of(ctx);

                        if (accountType == 0) {
                          if (selectedHotelId == null || selectedHotelId!.isEmpty) {
                            scaffold.showSnackBar(
                              const SnackBar(
                                content: Text('Pilih mitra hotel tempat administrator bertugas'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final hIdInt = int.tryParse(selectedHotelId!) ?? 1;
                          final hotelName = _hotelMap[selectedHotelId]?.name ?? 'Hotel';

                          try {
                            final ok = await SuperAdminService.instance.createHotelStaff(
                              hotelId: hIdInt,
                              fullName: name,
                              email: email,
                              password: pass,
                              phoneNumber: phoneCtrl.text.trim(),
                              nik: nikCtrl.text.trim(),
                              roleJabatan: selectedRoleJabatan,
                              shiftTugas: selectedShift,
                            );

                            nav.pop();
                            if (ok) {
                              scaffold.showSnackBar(
                                SnackBar(
                                  content: Text('Akun $selectedRoleJabatan untuk $hotelName berhasil dibuat!'),
                                  backgroundColor: const Color(0xFF16A34A),
                                ),
                              );
                              _loadUsers();
                            }
                          } catch (e) {
                            scaffold.showSnackBar(
                              SnackBar(
                                content: Text('Gagal membuat akun hotel staff: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          // Tamu
                          final ok = await SuperAdminService.instance.createUser(
                            fullName: name,
                            email: email,
                            password: pass,
                            phoneNumber: phoneCtrl.text.trim(),
                          );
                          nav.pop();
                          if (ok) {
                            scaffold.showSnackBar(
                              const SnackBar(
                                content: Text('Pengguna tamu baru berhasil ditambahkan!'),
                                backgroundColor: Color(0xFF16A34A),
                              ),
                            );
                            _loadUsers();
                          } else {
                            scaffold.showSnackBar(
                              const SnackBar(
                                content: Text('Gagal menambahkan pengguna baru'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        accountType == 0 ? '+ Daftarkan Akun Staf Hotel' : '+ Daftarkan Pengguna Tamu',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showUserDetail(UserModel u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE0F4FB),
              child: Text(
                u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00758F),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                u.fullName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID Pengguna', u.id),
            _buildDetailRow('Email', u.email ?? '-'),
            _buildDetailRow('No. Telepon', u.phoneNumber ?? '-'),
            _buildDetailRow('Role Sistem', u.role.displayName),
            if (u.isHotelStaff)
              _buildDetailRow(
                'Mitra Hotel',
                _hotelMap[u.managedHotelId]?.name ??
                    (u.managedHotelId != null ? 'Hotel #${u.managedHotelId}' : '-'),
              ),
            _buildDetailRow('Status Akun', u.isActive ? 'Aktif' : 'Tersuspend'),
            if (u.createdAt != null)
              _buildDetailRow(
                'Terdaftar Pada',
                '${u.createdAt!.day}/${u.createdAt!.month}/${u.createdAt!.year}',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00758F),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _showEditUserModal(u);
            },
            child: const Text('Edit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Color(0xFF64748B))),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tamuCount = _users.where((u) => u.role == UserRole.customer).length;
    final staffCount = _users.where((u) => u.role != UserRole.customer).length;
    final aktifCount = _users.where((u) => u.isActive).length;

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Title & Super Admin Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Direktori Pengguna &\nStaf',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Kelola izin akses, akun tamu, serta status akun pengguna',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFCFFAFE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Super\nAdmin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0891B2),
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Tombol Tambah Pengguna Baru
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _showAddUserModal,
              icon: const Icon(Icons.person_add_alt_1_rounded,
                  size: 18, color: Colors.white),
              label: const Text(
                '+ Tambah Pengguna Baru',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C2FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 3. Mini Stat Box: Total, Tamu, Staf, Aktif
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                    'Total User', '${_users.length}', Icons.groups_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStat(
                    'Tamu', '$tamuCount', Icons.person_outline_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStat(
                    'Staf', '$staffCount', Icons.badge_outlined),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStat(
                    'Aktif', '$aktifCount', Icons.check_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4. Search Field
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari nama pengguna, email, atau no HP...',
                hintStyle:
                    const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                prefixIcon:
                    const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 5. Role Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua Peran (${_users.length})',
                  isSelected: _selectedRoleFilter == 'Semua',
                  onTap: () => setState(() => _selectedRoleFilter = 'Semua'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Tamu ($tamuCount)',
                  isSelected: _selectedRoleFilter == 'Tamu',
                  onTap: () => setState(() => _selectedRoleFilter = 'Tamu'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Staf Hotel ($staffCount)',
                  isSelected: _selectedRoleFilter == 'Staf Hotel',
                  onTap: () =>
                      setState(() => _selectedRoleFilter = 'Staf Hotel'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 6. Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua Status',
                  isSelected: _selectedStatusFilter == 'Semua',
                  onTap: () => setState(() => _selectedStatusFilter = 'Semua'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Aktif ($aktifCount)',
                  isSelected: _selectedStatusFilter == 'Aktif',
                  onTap: () => setState(() => _selectedStatusFilter = 'Aktif'),
                  activeColor: const Color(0xFF16A34A),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Tersuspend (${_users.length - aktifCount})',
                  isSelected: _selectedStatusFilter == 'Tersuspend',
                  onTap: () =>
                      setState(() => _selectedStatusFilter = 'Tersuspend'),
                  activeColor: const Color(0xFFDC2626),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 7. Header Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HASIL DITEMUKAN (${_filteredUsers.length})',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 8. User Items
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredUsers.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: const [
                  Icon(Icons.people_outline,
                      size: 40, color: Color(0xFF94A3B8)),
                  SizedBox(height: 10),
                  Text(
                    'Tidak ada akun yang sesuai dengan filter',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Coba ubah kata kunci pencarian atau reset filter di atas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            )
          else ...[
            Builder(
              builder: (ctx) {
                final total = _filteredUsers.length;
                final maxPage = (total / 10).ceil();
                final safePage = _currentPage.clamp(1, maxPage > 0 ? maxPage : 1);
                final pagedUsers = paginateList(_filteredUsers, safePage, pageSize: 10);

                return Column(
                  children: [
                    ..._buildGroupedUserList(pagedUsers),
                    AppPaginationBar(
                      currentPage: safePage,
                      totalItems: total,
                      pageSize: 10,
                      itemLabel: 'pengguna',
                      primaryColor: const Color(0xFF00758F),
                      onPageChanged: (newPage) => setState(() => _currentPage = newPage),
                    ),
                  ],
                );
              },
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF00758F)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    final color = activeColor ?? const Color(0xFF007A94);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? color : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupedUserList(List<UserModel> userList) {
    final widgets = <Widget>[];

    final hotelStaffList =
        userList.where((u) => u.isHotelStaff).toList();
    final customerList =
        userList.where((u) => u.role == UserRole.customer).toList();

    // 1. Tampilkan Karyawan Hotel (Dikelompokkan berdasarkan Mitra Hotel)
    if (_selectedRoleFilter != 'Tamu' && hotelStaffList.isNotEmpty) {
      widgets.add(
        Row(
          children: [
            const Icon(Icons.apartment_rounded,
                size: 16, color: Color(0xFF00758F)),
            const SizedBox(width: 6),
            Text(
              'KARYAWAN HOTEL BERDASARKAN MITRA (${hotelStaffList.length})',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF00758F),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
      widgets.add(const SizedBox(height: 8));

      // Kelompokkan per hotel
      final Map<String, List<UserModel>> staffByHotel = {};
      final List<UserModel> unassignedStaff = [];

      for (final staff in hotelStaffList) {
        final hId = staff.managedHotelId;
        if (hId != null && hId.isNotEmpty) {
          staffByHotel.putIfAbsent(hId, () => []).add(staff);
        } else {
          unassignedStaff.add(staff);
        }
      }

      // Render setiap hotel group
      staffByHotel.forEach((hotelId, staffList) {
        final hotel = _hotelMap[hotelId];
        final hotelName = hotel?.name ?? 'Mitra Penginapan #$hotelId';
        final hotelCity = hotel?.city ?? '';

        // Urutkan: Administrator pertama, lalu front_office, lalu maintenance
        staffList.sort((a, b) {
          int priority(UserRole r) {
            if (r == UserRole.adminHotel) return 0;
            if (r == UserRole.staffFo) return 1;
            if (r == UserRole.maintenance) return 2;
            return 3;
          }

          return priority(a.role).compareTo(priority(b.role));
        });

        widgets.add(_buildHotelStaffGroupCard(
          hotelName: hotelName,
          hotelCity: hotelCity,
          staffList: staffList,
        ));
        widgets.add(const SizedBox(height: 12));
      });

      // Jika ada staf tanpa hotel
      if (unassignedStaff.isNotEmpty) {
        widgets.add(_buildHotelStaffGroupCard(
          hotelName: 'Karyawan Tanpa Penginapan Terdaftar',
          hotelCity: '',
          staffList: unassignedStaff,
        ));
        widgets.add(const SizedBox(height: 12));
      }
    }

    // 2. Tampilkan Tamu / Customer
    if (_selectedRoleFilter != 'Staf Hotel' && customerList.isNotEmpty) {
      if (_selectedRoleFilter == 'Semua' && hotelStaffList.isNotEmpty) {
        widgets.add(const SizedBox(height: 10));
        widgets.add(
          Row(
            children: [
              const Icon(Icons.people_outline_rounded,
                  size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                'DAFTAR TAMU / PELANGGAN (${customerList.length})',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
        widgets.add(const SizedBox(height: 8));
      }

      for (final u in customerList) {
        widgets.add(_buildUserItem(u));
        widgets.add(const SizedBox(height: 10));
      }
    }

    return widgets;
  }

  Widget _buildHotelStaffGroupCard({
    required String hotelName,
    required String hotelCity,
    required List<UserModel> staffList,
  }) {
    final adminCount =
        staffList.where((u) => u.role == UserRole.adminHotel).length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hotel Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(
                bottom: BorderSide(color: Color(0xFFDCFCE7), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0x1F16A34A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.apartment_rounded,
                          size: 18,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotelName,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (hotelCity.isNotEmpty)
                              Text(
                                hotelCity,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: adminCount > 0
                        ? const Color(0xFF16A34A)
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${staffList.length} Karyawan${adminCount > 0 ? " • Ada Admin" : " • Belum Ada Admin"}',
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List of Staff within this Hotel
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: staffList.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 16, color: Color(0xFFF1F5F9)),
            itemBuilder: (ctx, idx) => _buildHotelStaffRow(staffList[idx]),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelStaffRow(UserModel u) {
    Color roleBadgeBg;
    Color roleBadgeText;
    String roleLabel;

    if (u.role == UserRole.adminHotel) {
      roleBadgeBg = const Color(0xFFCFFAFE);
      roleBadgeText = const Color(0xFF0891B2);
      roleLabel = 'Administrator';
    } else if (u.role == UserRole.staffFo) {
      roleBadgeBg = const Color(0xFFDBEAFE);
      roleBadgeText = const Color(0xFF2563EB);
      roleLabel = 'Front Office';
    } else {
      roleBadgeBg = const Color(0xFFFEF3C7);
      roleBadgeText = const Color(0xFFD97706);
      roleLabel = 'Maintenance';
    }

    return Row(
      children: [
        // Avatar
        GestureDetector(
          onTap: () => _showUserDetail(u),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: roleBadgeBg,
            child: Text(
              u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : 'S',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: roleBadgeText,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Name & Email
        Expanded(
          child: GestureDetector(
            onTap: () => _showUserDetail(u),
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        u.fullName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: roleBadgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        roleLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: roleBadgeText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${u.email ?? '-'} • ${u.phoneNumber ?? '-'} (ID: ${u.id})',
                  style:
                      const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: u.isActive
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      u.isActive ? 'Aktif' : 'Nonaktif / Tersuspend',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: u.isActive
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Popup Menu
        PopupMenuButton<String>(
          icon:
              const Icon(Icons.more_vert, size: 18, color: Color(0xFF64748B)),
          onSelected: (val) {
            if (val == 'detail') {
              _showUserDetail(u);
            } else if (val == 'edit') {
              _showEditUserModal(u);
            } else if (val == 'toggle') {
              _toggleStatus(u);
            } else if (val == 'delete') {
              _deleteUser(u);
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(
              value: 'detail',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFF00758F)),
                  SizedBox(width: 8),
                  Text('Lihat Detail', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0284C7)),
                  SizedBox(width: 8),
                  Text('Edit Akun', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    u.isActive ? Icons.block : Icons.check_circle_outline,
                    size: 16,
                    color: u.isActive
                        ? const Color(0xFFD97706)
                        : const Color(0xFF16A34A),
                  ),
                  SizedBox(width: 8),
                  Text(
                    u.isActive ? 'Nonaktifkan Akun' : 'Aktifkan Akun',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Hapus Akun',
                      style: TextStyle(fontSize: 12, color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserItem(UserModel u) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => _showUserDetail(u),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFE0F4FB),
              child: Text(
                u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00758F),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: GestureDetector(
              onTap: () => _showUserDetail(u),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          u.fullName,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: u.role == UserRole.customer
                              ? const Color(0xFFF1F5F9)
                              : const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          u.role.displayName,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: u.role == UserRole.customer
                                ? const Color(0xFF475569)
                                : const Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${u.email ?? '-'} • ${u.phoneNumber ?? '-'}',
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: u.isActive
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        u.isActive ? 'Aktif' : 'Tersuspend',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: u.isActive
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Actions Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF64748B)),
            onSelected: (val) {
              if (val == 'detail') {
                _showUserDetail(u);
              } else if (val == 'edit') {
                _showEditUserModal(u);
              } else if (val == 'toggle') {
                _toggleStatus(u);
              } else if (val == 'delete') {
                _deleteUser(u);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'detail',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Color(0xFF00758F)),
                    SizedBox(width: 8),
                    Text('Lihat Detail', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0284C7)),
                    SizedBox(width: 8),
                    Text('Edit Akun', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(
                      u.isActive ? Icons.block : Icons.check_circle_outline,
                      size: 16,
                      color: u.isActive
                          ? const Color(0xFFD97706)
                          : const Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      u.isActive ? 'Suspend / Nonaktifkan' : 'Aktifkan Akun',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus Akun',
                        style: TextStyle(fontSize: 12, color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
