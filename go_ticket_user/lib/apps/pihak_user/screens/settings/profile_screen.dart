import 'package:flutter/material.dart';

import 'package:go_ticket_user/core/config/supabase_config.dart';
import 'package:go_ticket_user/core/services/auth_service.dart';
import 'package:go_ticket_user/core/services/supabase_service.dart';
import 'package:go_ticket_user/core/utils/storage_helper.dart';
import 'package:go_ticket_user/core/widgets/gt_ui.dart';

/// Edit Profil Saya (Figma: "USER Page Profil Saya").
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  final _address = TextEditingController();
  late String _email;
  String? _avatarUrl;

  DateTime? _birth;
  bool? _male;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    _name = TextEditingController(text: user?.fullName ?? '');
    _phone = TextEditingController(text: user?.phoneNumber ?? '');
    _email = user?.email ?? 'user@goticket.com';
    _avatarUrl = user?.avatarUrl;
    _loadProfileFromSupabase();
  }

  Future<void> _loadProfileFromSupabase() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final sb = SupabaseService.instance;
    if (sb.isReady && sb.client != null) {
      try {
        final uid = int.tryParse(user.id);
        if (uid != null) {
          final res = await sb
              .table(SupabaseConfig.tableUsers)
              ?.select()
              .eq('id_user', uid)
              .maybeSingle();
          if (res != null && mounted) {
            setState(() {
              if (res['nama_lengkap'] != null &&
                  res['nama_lengkap'].toString().isNotEmpty) {
                _name.text = res['nama_lengkap'];
              }
              if (res['no_telepon'] != null &&
                  res['no_telepon'].toString().isNotEmpty) {
                _phone.text = res['no_telepon'];
              }
              if (res['alamat_domisili'] != null &&
                  res['alamat_domisili'].toString().isNotEmpty) {
                _address.text = res['alamat_domisili'];
              }
              if (res['jenis_kelamin'] != null &&
                  res['jenis_kelamin'].toString().isNotEmpty) {
                final g = res['jenis_kelamin'].toString().toLowerCase();
                if (g.contains('laki')) {
                  _male = true;
                } else if (g.contains('perempuan')) {
                  _male = false;
                }
              }
              if (res['tanggal_lahir'] != null) {
                final d = DateTime.tryParse(res['tanggal_lahir'].toString());
                if (d != null) _birth = d;
              }
            });
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching profile: $e');
      }
    }
    // Muat avatar URL dari SharedPreferences (bukan dari DB — kolom tidak ada)
    final savedAvatar = await StorageHelper.getAvatarUrl();
    if (savedAvatar != null && savedAvatar.isNotEmpty && mounted) {
      setState(() => _avatarUrl = savedAvatar);
    }
  }

  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _birth = d);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama lengkap wajib diisi')));
      return;
    }
    try {
      await AuthService.instance.updateProfile(
        fullName: _name.text.trim(),
        phone: _phone.text.trim(),
        avatarUrl: _avatarUrl,
        birthDate: _birth,
        gender: _male == null ? null : (_male! ? 'Laki-laki' : 'Perempuan'),
        address: _address.text.trim().isNotEmpty ? _address.text.trim() : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil disimpan ke Supabase')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GT.bg,
      appBar: const GTAppBar(title: 'Edit Profil'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          GTCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informasi Akun',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: GT.ink,
                  ),
                ),
                const SizedBox(height: 14),
                _label('Nama Lengkap'),
                _input(_name, Icons.badge_outlined,
                    onChanged: (_) => setState(() {})),
                const SizedBox(height: 14),
                _label('Alamat Email'),
                _static(Icons.mail_outline, _email),
                const SizedBox(height: 14),
                _label('Nomor Ponsel'),
                _input(
                  _phone,
                  Icons.phone_outlined,
                  type: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                _label('Tanggal Lahir'),
                GestureDetector(
                  onTap: _pickDate,
                  child: _static(
                      Icons.cake_outlined,
                      _birth != null
                          ? '${_birth!.day} ${_months[_birth!.month - 1]} ${_birth!.year}'
                          : 'Pilih tanggal lahir (opsional)',
                      trailing: const Icon(Icons.calendar_month_outlined,
                          color: GT.teal)),
                ),
                const SizedBox(height: 14),
                _label('Jenis Kelamin'),
                Row(children: [
                  _gender('Laki-laki', Icons.male, _male == true,
                      () => setState(() => _male = true)),
                  const SizedBox(width: 10),
                  _gender('Perempuan', Icons.female, _male == false,
                      () => setState(() => _male = false)),
                ]),
                const SizedBox(height: 14),
                _label('Alamat Domisili'),
                Container(
                  decoration: BoxDecoration(
                      color: GT.soft.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14)),
                  child: TextField(
                    controller: _address,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan alamat domisili lengkap (opsional)',
                      hintStyle: TextStyle(color: GT.muted, fontSize: 13),
                      border: InputBorder.none,
                      prefixIcon: Align(
                        widthFactor: 1,
                        heightFactor: 1,
                        child: Icon(Icons.location_on_outlined,
                            color: GT.teal),
                      ),
                      contentPadding: EdgeInsets.all(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: GTBottomBar(
        child: Row(children: [
          Expanded(
            flex: 2,
            child: GTButton(
              label: 'Batalkan',
              color: GT.soft,
              textColor: GT.ink,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: GTButton(
              label: 'Simpan Perubahan',
              leading: Icons.check,
              onTap: _save,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: GT.body)),
      );

  Widget _input(TextEditingController c, IconData icon,
      {bool readOnly = false,
      TextInputType? type,
      Widget? trailing,
      ValueChanged<String>? onChanged}) {
    return Container(
      decoration: BoxDecoration(
          color: GT.soft.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: c,
        readOnly: readOnly,
        keyboardType: type,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: GT.ink),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: GT.teal, size: 20),
          suffixIcon: trailing == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Align(
                      widthFactor: 1, heightFactor: 1, child: trailing),
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _static(IconData icon, String text, {Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
          color: GT.soft.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Icon(icon, color: GT.teal, size: 20),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 14, color: GT.ink))),
        if (trailing != null) trailing,
      ]),
    );
  }

  Widget _gender(String t, IconData i, bool on, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              color: on ? GT.sky : GT.soft.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(24)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(i, size: 18, color: GT.ink),
            const SizedBox(width: 6),
            Text(t,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: GT.ink)),
          ]),
        ),
      ),
    );
  }
}
