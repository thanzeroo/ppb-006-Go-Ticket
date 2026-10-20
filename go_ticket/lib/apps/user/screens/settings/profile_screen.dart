import 'package:flutter/material.dart';

import '../../widgets/gt_ui.dart';

/// Edit Profil Saya (Figma: "USER Page Profil Saya").
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController(text: 'Aditya Pratama');
  final _phone = TextEditingController(text: '+62 812-3456-7890');
  final _address = TextEditingController(text: 'Kec. Kuta, Kab. Badung, Bali');
  final _email = 'aditya.pratama@email.com';

  DateTime _birth = DateTime(1994, 8, 14);
  bool _male = true;
  bool _notif = true;
  bool _phoneEditable = false;
  String _language = 'Bahasa Indonesia';
  String _currency = 'IDR - Indonesian Rupiah (Rp)';

  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli',
    'Agustus', 'September', 'Oktober', 'November', 'Desember'
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
      initialDate: _birth,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _birth = d);
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama lengkap wajib diisi')));
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profil berhasil disimpan')));
    Navigator.of(context).pop();
  }

  Future<void> _choose(String title, List<String> options, String current,
      ValueChanged<String> onPick) async {
    final v = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          for (final o in options)
            ListTile(
              title: Text(o),
              trailing: o == current
                  ? const Icon(Icons.check, color: GT.primary)
                  : null,
              onTap: () => Navigator.pop(ctx, o),
            ),
        ]),
      ),
    );
    if (v != null) onPick(v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GT.bg,
      appBar: const GTAppBar(title: 'Profile'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          GTCard(
            child: Row(children: [
              Stack(children: [
                const CircleAvatar(
                    radius: 38,
                    backgroundColor: GT.sky,
                    child: Icon(Icons.person, size: 44, color: GT.teal)),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Ganti foto segera hadir'))),
                    child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: GT.teal,
                        child: Icon(Icons.photo_camera,
                            size: 14, color: Colors.white)),
                  ),
                ),
              ]),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(_name.text,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: GT.ink)),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: GT.teal, size: 18),
                    ]),
                    const SizedBox(height: 4),
                    const GTChip('Go Ticket Gold Member',
                        icon: Icons.workspace_premium, bg: GT.sky),
                    const SizedBox(height: 6),
                    Row(children: const [
                      Text('Saldo Poin: ',
                          style: TextStyle(fontSize: 12, color: GT.muted)),
                      GTChip('2.450 Poin', bg: GT.soft, fg: GT.teal),
                    ]),
                  ],
                ),
              ),
            ]),
          ),
          GTCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: const [
                  Expanded(
                    child: Text('Informasi Akun',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: GT.ink)),
                  ),
                  Text('WAJIB DIISI',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: GT.teal)),
                ]),
                const SizedBox(height: 14),
                _label('Nama Lengkap'),
                _input(_name, Icons.badge_outlined,
                    onChanged: (_) => setState(() {})),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _label('Alamat Email')),
                  const GTChip('Terverifikasi',
                      icon: Icons.check_circle, bg: GT.sky),
                ]),
                _static(Icons.mail_outline, _email),
                const SizedBox(height: 14),
                _label('Nomor Ponsel'),
                _input(_phone, Icons.phone_outlined,
                    readOnly: !_phoneEditable,
                    type: TextInputType.phone,
                    trailing: GestureDetector(
                      onTap: () =>
                          setState(() => _phoneEditable = !_phoneEditable),
                      child: GTChip(_phoneEditable ? 'Selesai' : 'Ubah',
                          bg: GT.sky),
                    )),
                const SizedBox(height: 14),
                _label('Tanggal Lahir'),
                GestureDetector(
                  onTap: _pickDate,
                  child: _static(
                      Icons.cake_outlined,
                      '${_birth.day} ${_months[_birth.month - 1]} ${_birth.year}',
                      trailing: const Icon(Icons.calendar_month_outlined,
                          color: GT.teal)),
                ),
                const SizedBox(height: 14),
                _label('Jenis Kelamin'),
                Row(children: [
                  _gender('Laki-laki', Icons.male, _male,
                      () => setState(() => _male = true)),
                  const SizedBox(width: 10),
                  _gender('Perempuan', Icons.female, !_male,
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
          GTCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Preferensi & Keamanan',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: GT.ink)),
                const SizedBox(height: 12),
                _prefRow(Icons.translate, 'Bahasa Aplikasi', _language,
                    onTap: () => _choose('Pilih Bahasa',
                        ['Bahasa Indonesia', 'English'], _language,
                        (v) => setState(() => _language = v))),
                _prefRow(Icons.payments_outlined, 'Mata Uang Pilihan',
                    _currency,
                    onTap: () => _choose(
                        'Pilih Mata Uang',
                        ['IDR - Indonesian Rupiah (Rp)', 'USD - US Dollar (\$)'],
                        _currency,
                        (v) => setState(() => _currency = v))),
                Row(children: [
                  const CircleAvatar(
                      radius: 20,
                      backgroundColor: GT.soft,
                      child: Icon(Icons.campaign_outlined, color: GT.teal)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notifikasi Booking & Promo',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, color: GT.ink)),
                        Text('Update tiket penerbangan & voucher',
                            style: TextStyle(fontSize: 11, color: GT.muted)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _notif,
                    activeColor: Colors.white,
                    activeTrackColor: GT.teal,
                    onChanged: (v) => setState(() => _notif = v),
                  ),
                ]),
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

  Widget _prefRow(IconData i, String t, String s, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Row(children: [
          CircleAvatar(
              radius: 20,
              backgroundColor: GT.soft,
              child: Icon(i, color: GT.teal)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: GT.ink)),
                Text(s,
                    style: const TextStyle(fontSize: 11, color: GT.muted)),
              ],
            ),
          ),
          const CircleAvatar(
              radius: 16,
              backgroundColor: GT.soft,
              child: Icon(Icons.chevron_right, color: GT.ink, size: 20)),
        ]),
      ),
    );
  }
}
