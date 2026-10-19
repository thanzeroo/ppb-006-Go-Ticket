import 'package:flutter/material.dart';

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

  late TextEditingController _nameController;
  late TextEditingController _nikController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _shiftController;
  late TextEditingController _startDateController;

  int _gender = 1; // 0: Laki-laki, 1: Perempuan
  int _selectedRole = 0; // 0: FO, 1: HK, 2: Maintenance, 3: Finance, 4: Duty Manager
  int _authMethod = 0; // 0: Email link, 1: Manual password
  bool _mustChangePass = true;
  bool _sendOnboardingWA = true;

  final Map<String, bool> _permissions = {
    'verify_res': true,
    'exec_checkin': true,
    'calc_checkout': true,
    'change_tariff': false,
    'finance_escrow': false,
    'view_room_hk': true,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Putu Ayu Saraswati');
    _nikController = TextEditingController(text: '5104035608980002');
    _emailController = TextEditingController(text: 'putu.saraswati@amoraresort.com');
    _phoneController = TextEditingController(text: '+62 812-3890-4421');
    _shiftController = TextEditingController(text: 'Shift Pagi (07.00 – 15.00 WITA)');
    _startDateController = TextEditingController(text: '01 November 2025');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _shiftController.dispose();
    _startDateController.dispose();
    super.dispose();
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
              'Tambah Karyawan',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF64748B), size: 20),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            // Top Badges
            _buildTopBadges(),

            const SizedBox(height: 16),
            // Card 1: Data Identitas & Kontak
            _buildIdentityCard(),

            const SizedBox(height: 16),
            // Card 2: Departemen & Role Jabatan
            _buildRoleDepartmentCard(),

            const SizedBox(height: 16),
            // Card 3: Hak Akses & Modul Operasional
            _buildAccessModuleCard(),

            const SizedBox(height: 16),
            // Card 4: Kredensial Awal & Keamanan
            _buildCredentialsSecurityCard(),

            const SizedBox(height: 24),
            // Bottom Action Bar
            _buildBottomButtons(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBadges() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.person_add_alt_1_outlined, size: 12, color: Color(0xFF0284C7)),
                  SizedBox(width: 4),
                  Text(
                    'FORM KARYAWAN BARU',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.badge_outlined, size: 12, color: Color(0xFF0284C7)),
                  SizedBox(width: 4),
                  Text(
                    'ID: #STF-2025-019',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.domain, size: 12, color: Color(0xFF64748B)),
            SizedBox(width: 4),
            Text(
              'The Grand Amora Resort & Spa • PROP-2025-089',
              style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIdentityCard() {
    return _buildSectionContainer(
      icon: Icons.badge_outlined,
      title: 'Data Identitas & Kontak',
      subtitle: 'Informasi legal & otentikasi akun internal',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo upload row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _cNormal, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.person, size: 30, color: Color(0xFF005E73)),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: _teal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Unggah Foto Formal Karyawan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      const Text('Format JPG, PNG (Maks. 2MB)', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007A87),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: const Size(0, 26),
                              textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                            child: const Text('Pilih Foto'),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF64748B)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          Row(
            children: const [
              Text('Nama Lengkap Karyawan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
              Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          _buildInput(controller: _nameController, suffixIcon: Icons.account_circle_outlined),

          const SizedBox(height: 12),
          Row(
            children: const [
              Text('Nomor Induk Kependudukan (NIK KTP)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
              Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          _buildInput(controller: _nikController, suffixIcon: Icons.credit_card),

          const SizedBox(height: 12),
          Row(
            children: const [
              Text('Email Login Operasional', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
              Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          _buildInput(controller: _emailController, suffixIcon: Icons.alternate_email),

          const SizedBox(height: 12),
          Row(
            children: const [
              Text('Nomor WhatsApp / Telepon Aktif', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
              Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          _buildInput(controller: _phoneController, suffixIcon: Icons.phone_android),

          const SizedBox(height: 12),
          const Text('Jenis Kelamin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _gender = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: _gender == 0 ? const Color(0xFFF0FDFE) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _gender == 0 ? const Color(0xFF38BDF8) : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _gender == 0 ? Icons.radio_button_checked : Icons.radio_button_off,
                          size: 16,
                          color: _gender == 0 ? const Color(0xFF007A87) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 8),
                        const Text('Laki-laki', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _gender = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: _gender == 1 ? const Color(0xFFF0FDFE) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _gender == 1 ? const Color(0xFF38BDF8) : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _gender == 1 ? Icons.radio_button_checked : Icons.radio_button_off,
                          size: 16,
                          color: _gender == 1 ? const Color(0xFF007A87) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 8),
                        const Text('Perempuan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDepartmentCard() {
    return _buildSectionContainer(
      icon: Icons.domain,
      title: 'Departemen & Role Jabatan',
      subtitle: 'Menentukan tata letak panel & alur operasional',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pilih Role Utama', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 8),

          _buildRoleOption(
            index: 0,
            title: 'Front Office / Resepsionis',
            badge: 'Aktif',
            badgeBg: const Color(0xFFE0F2FE),
            badgeFg: const Color(0xFF0284C7),
            desc: 'Akses Tamu, Registrasi Identitas, & Check-in FO',
          ),
          const SizedBox(height: 8),
          _buildRoleOption(
            index: 1,
            title: 'Housekeeping & Kebersihan',
            badge: 'Room Board',
            badgeBg: const Color(0xFFEDE9FE),
            badgeFg: const Color(0xFF7C3AED),
            desc: 'Akses Checklist Kebersihan & Turn Status Kamar',
          ),
          const SizedBox(height: 8),
          _buildRoleOption(
            index: 2,
            title: 'Maintenance & Engineering',
            badge: 'Fasilitas',
            badgeBg: const Color(0xFFE0E7FF),
            badgeFg: const Color(0xFF4338CA),
            desc: 'Tiket Kerusakan, Log Perbaikan, & Fasilitas Resort',
          ),
          const SizedBox(height: 8),
          _buildRoleOption(
            index: 3,
            title: 'Finance & Kasir Hotel',
            badge: 'Folio Kasir',
            badgeBg: const Color(0xFFE0E7FF),
            badgeFg: const Color(0xFF4338CA),
            desc: 'Rekonsiliasi Harian, Pembayaran & Settlement',
          ),
          const SizedBox(height: 8),
          _buildRoleOption(
            index: 4,
            title: 'Duty Manager / Supervisor',
            badge: 'Otorisasi',
            badgeBg: const Color(0xFFE0F2FE),
            badgeFg: const Color(0xFF0284C7),
            desc: 'Persetujuan Diskon, Kamar Pengganti & Emergency Override',
          ),

          const SizedBox(height: 14),
          const Text('Jadwal Shift Standar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          _buildInput(controller: _shiftController, suffixIcon: Icons.access_time),

          const SizedBox(height: 12),
          const Text('Tanggal Mulai Bekerja', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          _buildInput(controller: _startDateController, suffixIcon: Icons.calendar_today_outlined),
        ],
      ),
    );
  }

  Widget _buildRoleOption({
    required int index,
    required String title,
    required String badge,
    required Color badgeBg,
    required Color badgeFg,
    required String desc,
  }) {
    final isSel = _selectedRole == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFFF0FDFE) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSel ? const Color(0xFF38BDF8) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSel ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: isSel ? const Color(0xFF007A87) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(badge, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: badgeFg)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(desc, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessModuleCard() {
    return _buildSectionContainer(
      icon: Icons.shield_outlined,
      title: 'Hak Akses & Modul Operasional',
      subtitle: 'Permission matrix terapan pada Go Ticket Ops',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, size: 14, color: Color(0xFF0284C7)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Akses disesuaikan dengan template role: Front Office',
                    style: TextStyle(fontSize: 10, color: Color(0xFF0369A1), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          _buildCheckboxItem(
            keyName: 'verify_res',
            icon: Icons.qr_code_scanner,
            title: 'Verifikasi Reservasi & Scan QR E-Tiket',
            desc: 'Memvalidasi tiket online OTA & direct booking tamu',
          ),
          const SizedBox(height: 8),
          _buildCheckboxItem(
            keyName: 'exec_checkin',
            icon: Icons.vpn_key_outlined,
            title: 'Eksekusi Check-in & Penerbitan RFID Kunci',
            desc: 'Assign nomor kamar dan enkripsi kartu smart lock',
          ),
          const SizedBox(height: 8),
          _buildCheckboxItem(
            keyName: 'calc_checkout',
            icon: Icons.receipt_long_outlined,
            title: 'Kalkulasi Check-out & Billing Minibar',
            desc: 'Mencatat konsumsi kamar & mencetak final invoice',
          ),
          const SizedBox(height: 8),
          _buildCheckboxItem(
            keyName: 'change_tariff',
            icon: Icons.discount_outlined,
            title: 'Ubah Tarif Kamar & Diskon Promo',
            badge: 'Manager Only',
            desc: 'Wewenang otorisasi potongan harga kasir',
          ),
          const SizedBox(height: 8),
          _buildCheckboxItem(
            keyName: 'finance_escrow',
            icon: Icons.account_balance_outlined,
            title: 'Laporan Keuangan & Penarikan Escrow',
            badge: 'Finance & GM',
            desc: 'Audit rekonsiliasi transfer bank dan kasir',
          ),
          const SizedBox(height: 8),
          _buildCheckboxItem(
            keyName: 'view_room_hk',
            icon: Icons.cleaning_services_outlined,
            title: 'Lihat Status Kamar & Housekeeping Turn',
            desc: 'Pantau kesiapan kamar siap huni (Cleaned & Inspected)',
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxItem({
    required String keyName,
    required IconData icon,
    required String title,
    String? badge,
    required String desc,
  }) {
    final isChecked = _permissions[keyName] ?? false;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isChecked ? const Color(0xFFF0FDFE) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isChecked ? const Color(0xFFBAE6FD) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: isChecked,
            onChanged: (val) => setState(() => _permissions[keyName] = val ?? false),
            activeColor: const Color(0xFF007A87),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 16, color: isChecked ? const Color(0xFF007A87) : const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(badge, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF6D28D9))),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsSecurityCard() {
    return _buildSectionContainer(
      icon: Icons.lock_person_outlined,
      title: 'Kredensial Awal & Keamanan',
      subtitle: 'Metode aktivasi sandi pertama login staf',
      child: Column(
        children: [
          _buildAuthMethodRadio(
            index: 0,
            title: 'Kirim tautan aktivasi mandiri ke email',
            desc: 'Karyawan mengatur password pribadi langsung via email terverifikasi',
          ),
          const SizedBox(height: 8),
          _buildAuthMethodRadio(
            index: 1,
            title: 'Buat kata sandi sementara secara manual',
            desc: 'Generate password acak yang wajib diganti segera',
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _mustChangePass,
                  onChanged: (val) => setState(() => _mustChangePass = val ?? false),
                  activeColor: const Color(0xFF007A87),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 6),
                const Text('Wajib ganti sandi saat login perdana', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _sendOnboardingWA,
                  onChanged: (val) => setState(() => _sendOnboardingWA = val ?? false),
                  activeColor: const Color(0xFF007A87),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 6),
                const Text('Kirim panduan onboarding via WhatsApp', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              ],
            ),
          ),

          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.lock_outline, size: 12, color: Color(0xFF64748B)),
              SizedBox(width: 4),
              Text('Enkripsi 256-bit Go Ticket Security Compliance', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthMethodRadio({required int index, required String title, required String desc}) {
    final isSel = _authMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _authMethod = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFFF0FDFE) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSel ? const Color(0xFF38BDF8) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSel ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: isSel ? const Color(0xFF007A87) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text(desc, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Batal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Karyawan baru berhasil didaftarkan!'),
                  backgroundColor: _teal,
                ),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.person_add_alt_1, size: 16),
            label: const Text('Simpan & Daftarkan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInput({required TextEditingController controller, required IconData suffixIcon}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        suffixIcon: Icon(suffixIcon, size: 16, color: const Color(0xFF64748B)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
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
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
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
}
