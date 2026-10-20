import 'package:flutter/material.dart';

import '../../widgets/gt_ui.dart';

class _Guest {
  String name;
  String relation;
  String nik;
  String phone;
  String email;
  String birth;
  bool isChild;
  bool isMain;
  _Guest({
    required this.name,
    required this.relation,
    this.nik = '',
    this.phone = '',
    this.email = '',
    required this.birth,
    this.isChild = false,
    this.isMain = false,
  });

  String get initials {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.isEmpty || p.first.isEmpty) return '?';
    return (p.first[0] + (p.length > 1 ? p.last[0] : '')).toUpperCase();
  }
}

/// Data Tamu Tersimpan (Figma: "USER Page Data Tamu Tersimpan").
class SavedGuestsScreen extends StatefulWidget {
  const SavedGuestsScreen({super.key});

  @override
  State<SavedGuestsScreen> createState() => _SavedGuestsScreenState();
}

class _SavedGuestsScreenState extends State<SavedGuestsScreen> {
  int _filter = 0; // 0 semua, 1 dewasa, 2 anak

  final List<_Guest> _guests = [
    _Guest(
        name: 'Aditya Pratama',
        relation: 'Akun Utama',
        nik: '3171••••••••1004',
        phone: '+62 812-3456-7890',
        email: 'aditya.pratama@email.com',
        birth: '14 Agu 1994 (Dewasa)',
        isMain: true),
    _Guest(
        name: 'Siti Rahmawati',
        relation: 'Keluarga / Rekan',
        nik: '3273••••••••8821',
        phone: '+62 813-9876-5432',
        birth: ''),
    _Guest(
        name: 'Kenzo Pratama',
        relation: 'Anak Kandung',
        birth: '20 Mei 2019',
        isChild: true),
  ];

  List<_Guest> get _visible => _guests.where((g) {
        if (_filter == 1) return !g.isChild;
        if (_filter == 2) return g.isChild;
        return true;
      }).toList();

  int get _adults => _guests.where((g) => !g.isChild).length;
  int get _kids => _guests.where((g) => g.isChild).length;

  Future<void> _edit({_Guest? guest}) async {
    final isNew = guest == null;
    final name = TextEditingController(text: guest?.name ?? '');
    final nik = TextEditingController(text: guest?.nik ?? '');
    final phone = TextEditingController(text: guest?.phone ?? '');
    bool child = guest?.isChild ?? false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(isNew ? 'Tambah Tamu Baru' : 'Edit Data Tamu',
              style: const TextStyle(fontSize: 17)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nama lengkap')),
              if (!child)
                TextField(
                    controller: nik,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'No. KTP / NIK')),
              if (!child)
                TextField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    decoration:
                        const InputDecoration(labelText: 'No. Handphone')),
              if (isNew)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tamu anak-anak'),
                  value: child,
                  onChanged: (v) => setD(() => child = v),
                ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Simpan')),
          ],
        ),
      ),
    );

    if (ok == true && name.text.trim().isNotEmpty) {
      setState(() {
        if (isNew) {
          _guests.add(_Guest(
            name: name.text.trim(),
            relation: child ? 'Anak' : 'Keluarga / Rekan',
            nik: nik.text.trim(),
            phone: phone.text.trim(),
            birth: '',
            isChild: child,
          ));
        } else {
          guest.name = name.text.trim();
          guest.nik = nik.text.trim();
          guest.phone = phone.text.trim();
        }
      });
    }
    name.dispose();
    nik.dispose();
    phone.dispose();
  }

  Future<void> _delete(_Guest g) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tamu?'),
        content: Text('Data ${g.name} akan dihapus dari daftar tamu tersimpan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus', style: TextStyle(color: GT.red))),
        ],
      ),
    );
    if (ok == true) setState(() => _guests.remove(g));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GT.bg,
      appBar: const GTAppBar(title: 'Saved Guests'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: GT.soft, borderRadius: BorderRadius.circular(20)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const CircleAvatar(
                  radius: 20,
                  backgroundColor: GT.sky,
                  child: Icon(Icons.bolt, color: GT.teal)),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Booking Instan & Praktis',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: GT.teal)),
                    SizedBox(height: 2),
                    Text(
                        'Simpan data tamu untuk proses reservasi hotel 3× lebih cepat tanpa perlu ketik ulang setiap checkout.',
                        style: TextStyle(
                            fontSize: 12, height: 1.4, color: GT.body)),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          GTButton(
            label: '+ Tambah Tamu Baru',
            leading: Icons.person_add_alt_1_outlined,
            height: 56,
            onTap: () => _edit(),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _filterChip('Semua Tamu', _guests.length, 0),
              const SizedBox(width: 8),
              _filterChip('Dewasa', _adults, 1),
              const SizedBox(width: 8),
              _filterChip('Anak-anak', _kids, 2),
            ]),
          ),
          const SizedBox(height: 14),
          for (final g in _visible) _card(g),
          if (_visible.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                  child: Text('Belum ada data tamu',
                      style: TextStyle(color: GT.muted))),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: GT.soft, borderRadius: BorderRadius.circular(20)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              CircleAvatar(
                  radius: 18,
                  backgroundColor: GT.sky,
                  child: Icon(Icons.lock, size: 18, color: GT.teal)),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Keamanan Data Terjamin',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: GT.ink)),
                    SizedBox(height: 2),
                    Text(
                        'Data KTP & identitas diri Anda dienkripsi AES-256 dan hanya digunakan untuk validasi legal check-in resepsionis hotel mitra Go Ticket.',
                        style: TextStyle(
                            fontSize: 12, height: 1.4, color: GT.body)),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String t, int n, int idx) {
    final on = _filter == idx;
    return GestureDetector(
      onTap: () => setState(() => _filter = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            color: on ? GT.sky : GT.soft,
            borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Text(t,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: on ? GT.ink : GT.teal)),
          const SizedBox(width: 6),
          CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white,
              child: Text('$n',
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w800))),
        ]),
      ),
    );
  }

  Widget _row(IconData i, String l, String v, {bool mono = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Icon(i, size: 15, color: GT.muted),
          const SizedBox(width: 6),
          Text(l, style: const TextStyle(fontSize: 12, color: GT.body)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(v,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: mono ? 'monospace' : null,
                    color: GT.ink)),
          ),
        ]),
      );

  Widget _card(_Guest g) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: g.isMain
            ? const Border(left: BorderSide(color: GT.teal, width: 5))
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
              radius: 24,
              backgroundColor: g.isMain ? GT.sky : GT.soft,
              child: Text(g.initials,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: GT.ink))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.name,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: GT.ink)),
                Row(children: [
                  Icon(g.isMain ? Icons.verified_user : Icons.people_outline,
                      size: 13, color: GT.teal),
                  const SizedBox(width: 4),
                  Text(g.relation,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: GT.teal)),
                ]),
              ],
            ),
          ),
          GTChip(
              g.isMain
                  ? 'TAMU UTAMA'
                  : g.isChild
                      ? 'ANAK'
                      : 'DEWASA',
              bg: g.isMain ? GT.sky : GT.soft,
              fg: g.isMain ? GT.teal : GT.muted),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: GT.soft.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            if (g.nik.isNotEmpty)
              _row(Icons.badge_outlined, 'No. KTP / NIK', g.nik, mono: true),
            if (g.phone.isNotEmpty)
              _row(Icons.phone_outlined, 'No. Handphone', g.phone),
            if (g.email.isNotEmpty)
              _row(Icons.mail_outline, 'Email', g.email),
            if (g.birth.isNotEmpty)
              _row(Icons.cake_outlined, 'Tanggal Lahir', g.birth),
            if (g.isChild)
              _row(Icons.family_restroom, 'Kategori Usia',
                  '6 Tahun (Tarif Anak)'),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          if (g.isMain)
            const Expanded(
              child: Row(children: [
                Icon(Icons.check_circle, size: 16, color: GT.teal),
                SizedBox(width: 4),
                Text('Default Reservasi',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: GT.teal)),
              ]),
            )
          else if (g.isChild)
            const Expanded(
              child: Text('Tidak memerlukan nomor identitas KTP',
                  style: TextStyle(fontSize: 11, color: GT.body)),
            )
          else
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const GTChip('Booking Cepat',
                      icon: Icons.touch_app_outlined, bg: GT.sky),
                ),
              ),
            ),
          if (g.isMain)
            GestureDetector(
              onTap: () => _edit(guest: g),
              child: const GTChip('Edit Data',
                  icon: Icons.edit_outlined, bg: GT.soft, fg: GT.ink),
            )
          else ...[
            _iconBtn(Icons.edit_outlined, () => _edit(guest: g)),
            const SizedBox(width: 8),
            _iconBtn(Icons.delete_outline, () => _delete(g)),
          ],
        ]),
      ]),
    );
  }

  Widget _iconBtn(IconData i, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 38,
          height: 38,
          decoration:
              const BoxDecoration(color: GT.soft, shape: BoxShape.circle),
          child: Icon(i, size: 18, color: GT.ink),
        ),
      );
}
