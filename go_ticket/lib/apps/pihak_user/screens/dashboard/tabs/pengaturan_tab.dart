import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_ticket/core/services/auth_service.dart';
import 'package:go_ticket/core/services/customer_data_service.dart';
import 'package:go_ticket/core/widgets/user_avatar.dart';
import '../../auth/customer_login_screen.dart';
import '../../auth/terms_screen.dart';
import '../../settings/profile_screen.dart';
import '../../settings/saved_guests_screen.dart';
import '../../settings/security_screen.dart';
import '../../settings/voucher_screen.dart';
import '../customer_dashboard_screen.dart';
import 'pesanan_tab.dart';
import 'saved_hotel_screen.dart';

/// Tab Pengaturan / Profil User (Sesuai Desain Gambar 3)
class PengaturanTab extends StatefulWidget {
  const PengaturanTab({super.key});

  @override
  State<PengaturanTab> createState() => _PengaturanTabState();
}

class _PengaturanTabState extends State<PengaturanTab> {
  bool _notifEnabled = true;
  String _language = 'Bahasa Indonesia';
  int _savedGuestsCount = 0;
  int _savedHotelsCount = 0;
  int _points = 0;
  String _tier = 'MEMBER BRONZE GO TICKET';

  @override
  void initState() {
    super.initState();
    _loadDynamicCounts();
  }

  Future<void> _loadDynamicCounts() async {
    final guests = await CustomerDataService.instance.getSavedGuests();
    final hotels = await CustomerDataService.instance.getSavedHotels();
    final points = await CustomerDataService.instance.getRewardPoints();
    final tier = await CustomerDataService.instance.getMembershipTier();
    if (mounted) {
      setState(() {
        _savedGuestsCount = guests.length;
        _savedHotelsCount = hotels.length;
        _points = points;
        _tier = tier;
      });
    }
  }

  void _go(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) {
      setState(() {});
      _loadDynamicCounts();
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m)));

  Future<void> _showVerificationModal(String email) async {
    final otpController = TextEditingController(text: '1234');
    bool isVerifying = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F7FA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_outlined,
                    color: Color(0xFF00B4D8),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Verifikasi Akun Anda',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Masukkan 4-digit kode verifikasi yang kami kirim ke:\n$email',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: otpController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  style: const TextStyle(
                    fontSize: 22,
                    letterSpacing: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00B4D8),
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B4D8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isVerifying
                        ? null
                        : () async {
                            setModalState(() => isVerifying = true);
                            await AuthService.instance.verifyAccount(
                              otpCode: otpController.text,
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              setState(() {});
                              _snack('Akun berhasil diverifikasi!');
                            }
                          },
                    child: isVerifying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Verifikasi Sekarang',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari Akun?'),
        content: const Text(
            'Anda akan keluar dari sesi ini dan perlu masuk kembali untuk memesan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Keluar',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CustomerLoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final fullName =
        (user?.fullName.isNotEmpty == true) ? user!.fullName : 'Aditya Pratama';
    final email =
        (user?.email?.isNotEmpty == true) ? user!.email! : 'aditya.pratama@email.com';
    final isVerified = user?.isVerified ?? true;
    final points = _points;
    final tier = _tier;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(user),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(user, fullName, email, isVerified, tier),
                  const SizedBox(height: 12),
                  _buildSaldoCard(points),
                  const SizedBox(height: 24),
                  _buildSectionLabel('AKUN & KEAMANAN'),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profil Saya',
                      subtitle: 'Ubah nama, nomor HP & tanggal lahir',
                      onTap: () => _go(const ProfileScreen()),
                    ),
                    const Divider(
                        height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                    _buildMenuItem(
                      icon: Icons.people_outline,
                      title: 'Data Tamu Tersimpan',
                      subtitle: 'Isi cepat data penumpang & tamu hotel',
                      badge: '$_savedGuestsCount Tamu',
                      badgeColor: const Color(0xFF00B4D8),
                      onTap: () => _go(const SavedGuestsScreen()),
                    ),
                    const Divider(
                        height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                    _buildMenuItem(
                      icon: Icons.lock_outline,
                      title: 'Keamanan Akun & Kata Sandi',
                      subtitle: 'Ganti password & otentikasi 2 langkah',
                      onTap: () => _go(const SecurityScreen()),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionLabel('RESERVASI & TRANSAKSI'),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.receipt_long_outlined,
                      title: 'Riwayat Pesanan & E-Tiket Saya',
                      subtitle: 'Akses tiket aktif, voucher hotel & invoice',
                      onTap: () {
                        PesananTab.subTabNotifier.value = 0;
                        CustomerDashboardScreen.tabNotifier.value = 2;
                      },
                    ),
                    const Divider(
                        height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                    _buildMenuItem(
                      icon: Icons.favorite_outline,
                      title: 'Penginapan Tersimpan',
                      subtitle: 'Daftar villa & resort favorit Anda',
                      badge: '$_savedHotelsCount Hotel',
                      badgeColor: const Color(0xFF00B4D8),
                      onTap: () {
                        PesananTab.subTabNotifier.value = 1;
                        CustomerDashboardScreen.tabNotifier.value = 2;
                      },
                    ),
                    const Divider(
                        height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                    _buildMenuItem(
                      icon: Icons.local_offer_outlined,
                      title: 'Voucher & Promo Saya',
                      subtitle: 'Diskon eksklusif member Platinum',
                      badge: '2 Baru',
                      badgeColor: const Color(0xFF00B4D8),
                      onTap: () => _go(const VoucherScreen()),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionLabel('PENGATURAN APLIKASI'),
                  _buildMenuCard([
                    _buildMenuItemSwitch(
                      icon: Icons.notifications_outlined,
                      title: 'Notifikasi Booking & Promo',
                      subtitle: 'Pemberitahuan check-in & diskon kilat',
                      value: _notifEnabled,
                      onChanged: (val) => setState(() => _notifEnabled = val),
                    ),
                    const Divider(
                        height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                    _buildMenuItemValue(
                      icon: Icons.translate,
                      title: 'Pilihan Bahasa',
                      subtitle: 'Bahasa tampilan sistem',
                      value: _language,
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionLabel('BANTUAN & KEBIJAKAN'),
                  _buildMenuCard([
                    _buildMenuItemDot(
                      icon: Icons.headset_mic_outlined,
                      title: 'Pusat Bantuan & CS 24/7',
                      subtitle: 'Respon cepat via WhatsApp resmi',
                      onTap: () => _snack('Menghubungkan ke CS WhatsApp…'),
                    ),
                    const Divider(
                        height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                    _buildMenuItem(
                      icon: Icons.policy_outlined,
                      title: 'Kebijakan Privasi & Ketentuan',
                      subtitle: 'Syarat penggunaan Go Ticket',
                      onTap: () => _go(const TermsScreen()),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                  const SizedBox(height: 14),
                  _buildFooter(),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP BAR
  // ---------------------------------------------------------------------------
  Widget _buildTopBar(dynamic user) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 28,
              errorBuilder: (_, __, ___) => Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B4D8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'GO',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'GoTicket',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            UserAvatar(
              name: user?.fullName ?? 'Aditya Pratama',
              radius: 19,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PROFILE CARD (Sesuai Gambar 3)
  // ---------------------------------------------------------------------------
  Widget _buildProfileCard(
    dynamic user,
    String fullName,
    String email,
    bool isVerified,
    String tier,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F7FD),
            Color(0xFFF0F9FE),
            Color(0xFFF8FAFC),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          UserAvatar(
            name: fullName,
            radius: 30,
            showVerifiedBadge: isVerified,
          ),
          const SizedBox(width: 14),
          // Info User
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        fullName,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    if (isVerified)
                      const Icon(Icons.verified,
                          color: Color(0xFF0077B6), size: 18)
                    else
                      InkWell(
                        onTap: () => _showVerificationModal(email),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Verifikasi',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Tier Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8F0FA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium,
                          color: Color(0xFF0077B6), size: 13),
                      const SizedBox(width: 4),
                      Text(
                        tier,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0077B6),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SALDO POIN REWARD CARD
  // ---------------------------------------------------------------------------
  Widget _buildSaldoCard(int points) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFC8F0FA),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars, color: Color(0xFF0077B6), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo Poin Reward',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$points ',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0077B6),
                      ),
                    ),
                    Text(
                      'Poin',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _go(const VoucherScreen()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B4D8),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Tukar Poin',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER MENU BUILDERS
  // ---------------------------------------------------------------------------
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF64748B),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF0077B6), size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: const Color(0xFF64748B),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (badgeColor ?? const Color(0xFF00B4D8)).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: badgeColor ?? const Color(0xFF0077B6),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildMenuItemSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF0077B6), size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: const Color(0xFF64748B),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF00B4D8),
      ),
    );
  }

  Widget _buildMenuItemValue({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF0077B6), size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: const Color(0xFF64748B),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildMenuItemDot({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF0077B6), size: 20),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF00B4D8),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: const Color(0xFF64748B),
        ),
      ),
      trailing: const Icon(Icons.chevron_right,
          size: 18, color: Color(0xFF94A3B8)),
    );
  }

  // ---------------------------------------------------------------------------
  // LOGOUT & FOOTER
  // ---------------------------------------------------------------------------
  Widget _buildLogoutButton() {
    return InkWell(
      onTap: _logout,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded,
                color: Color(0xFFEF4444), size: 18),
            const SizedBox(width: 8),
            Text(
              'Keluar dari Akun',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'Go Ticket v3.12.0 • Keamanan Terverifikasi',
        style: GoogleFonts.inter(
          fontSize: 11,
          color: const Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
