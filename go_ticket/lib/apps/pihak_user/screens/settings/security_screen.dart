import 'package:flutter/material.dart';

import '../../widgets/gt_ui.dart';

/// Keamanan Akun & Kata Sandi (Figma: "USER Page KeamananAkun&KataSandi").
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _hideOld = true, _hideNew = true, _hideConfirm = true;
  bool _twoFa = true;
  bool _bio = true;
  bool _passwordUpdated = false;

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _okLen => _new.text.length >= 8;
  bool get _okCase =>
      RegExp(r'[a-z]').hasMatch(_new.text) &&
      RegExp(r'[A-Z]').hasMatch(_new.text);
  bool get _okSym =>
      RegExp(r'[0-9]').hasMatch(_new.text) &&
      RegExp(r'[^A-Za-z0-9]').hasMatch(_new.text);

  double get _score {
    var s = 0.55;
    if (_twoFa) s += 0.15;
    if (_bio) s += 0.1;
    if (_passwordUpdated) s += 0.15;
    return s.clamp(0.0, 1.0);
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m)));

  void _updatePassword() {
    if (_old.text.isEmpty) return _snack('Masukkan kata sandi saat ini');
    if (!(_okLen && _okCase && _okSym)) {
      return _snack('Kata sandi baru belum memenuhi kriteria keamanan');
    }
    if (_new.text != _confirm.text) {
      return _snack('Konfirmasi kata sandi tidak sama');
    }
    setState(() {
      _passwordUpdated = true;
      _old.clear();
      _new.clear();
      _confirm.clear();
    });
    _snack('Kata sandi berhasil diperbarui');
  }

  Future<void> _changePin() async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah PIN Transaksi'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          decoration: const InputDecoration(hintText: 'PIN baru (6 digit)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, c.text.length == 6),
              child: const Text('Simpan')),
        ],
      ),
    );
    c.dispose();
    if (ok == true) _snack('PIN transaksi berhasil diubah');
  }

  Future<void> _confirm2(String title, String body, String action,
      VoidCallback onYes) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(action, style: const TextStyle(color: GT.red))),
        ],
      ),
    );
    if (ok == true) onYes();
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_score * 100).round();
    return Scaffold(
      backgroundColor: GT.bg,
      appBar: const GTAppBar(title: 'Security'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          GTCard(
            child: Column(children: [
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GTChip('PROTEKSI TINGKAT TINGGI',
                          icon: Icons.shield, bg: GT.sky),
                      const SizedBox(height: 8),
                      const Text('Skor Keamanan Akun',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: GT.ink)),
                      Text('$pct% • ${pct >= 80 ? 'Sangat Baik' : 'Cukup'}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, color: GT.teal)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(alignment: Alignment.center, children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        value: _score,
                        strokeWidth: 7,
                        backgroundColor: GT.soft,
                        color: GT.primary,
                      ),
                    ),
                    Text('$pct%',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, color: GT.ink)),
                  ]),
                ),
              ]),
              const Divider(height: 22),
              Row(children: const [
                Icon(Icons.lightbulb_outline, color: GT.teal, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Perbarui kata sandi berkala untuk meraih perlindungan optimal 100%.',
                      style: TextStyle(fontSize: 12, color: GT.body)),
                ),
              ]),
            ]),
          ),
          GTCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _header(Icons.lock_reset, 'Ubah Kata Sandi',
                  'Kelola kombinasi sandi akun Anda'),
              _pw('Kata Sandi Saat Ini', 'Masukkan kata sandi lama', _old,
                  _hideOld, () => setState(() => _hideOld = !_hideOld)),
              const SizedBox(height: 12),
              _pw('Kata Sandi Baru', 'Buat kata sandi baru', _new, _hideNew,
                  () => setState(() => _hideNew = !_hideNew),
                  onChanged: (_) => setState(() {})),
              const SizedBox(height: 12),
              _pw('Konfirmasi Kata Sandi Baru', 'Ulangi kata sandi baru',
                  _confirm, _hideConfirm,
                  () => setState(() => _hideConfirm = !_hideConfirm)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: GT.soft.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('KRITERIA KEAMANAN:',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: GT.ink)),
                      const SizedBox(height: 6),
                      _crit('Minimal 8 karakter', _okLen),
                      _crit('Kombinasi huruf besar & kecil', _okCase),
                      _crit('Mengandung angka & simbol khusus', _okSym),
                    ]),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: GTButton(
                    label: 'Perbarui Kata Sandi',
                    leading: Icons.vpn_key_outlined,
                    onTap: _updatePassword),
              ),
            ]),
          ),
          GTCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _header(Icons.shield_outlined, 'Autentikasi & Verifikasi',
                  'Lapisan proteksi ekstra saat transaksi'),
              _toggle(Icons.sms_outlined, 'Verifikasi 2 Langkah (2FA)',
                  'Kode OTP WhatsApp & SMS', _twoFa,
                  (v) => setState(() => _twoFa = v)),
              const SizedBox(height: 10),
              _toggle(Icons.fingerprint, 'Login Biometrik',
                  'Face ID atau sensor sidik jari', _bio,
                  (v) => setState(() => _bio = v)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: GT.soft.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const Icon(Icons.pin_outlined, color: GT.teal),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(spacing: 6, children: [
                          Text('PIN Transaksi & E-Tiket',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: GT.ink)),
                          GTChip('6 Digit Aktif', bg: GT.sky),
                        ]),
                        Text('Digunakan saat cetak & klaim tiket',
                            style:
                                TextStyle(fontSize: 11, color: GT.muted)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _changePin,
                    child: const GTChip('Ubah PIN',
                        bg: GT.soft, fg: GT.teal),
                  ),
                ]),
              ),
            ]),
          ),
          GTCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: _header(Icons.devices_other, 'Perangkat Terhubung',
                      'Sesi login aktif saat ini'),
                ),
                const GTChip('2 Perangkat', bg: GT.soft, fg: GT.muted),
              ]),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: GT.soft.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const CircleAvatar(
                      radius: 22,
                      backgroundColor: GT.sky,
                      child: Icon(Icons.smartphone, color: GT.teal)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Wrap(spacing: 6, children: [
                          Text('iPhone 15 Pro',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: GT.ink)),
                          GTChip('Perangkat Ini', bg: GT.sky),
                        ]),
                        Text('Jakarta, Indonesia • Aktif sekarang',
                            style:
                                TextStyle(fontSize: 11, color: GT.muted)),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: GT.soft.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const CircleAvatar(
                      radius: 22,
                      backgroundColor: GT.soft,
                      child: Icon(Icons.laptop_mac, color: GT.teal)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chrome Mac OS',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, color: GT.ink)),
                        Text('Bali, Indonesia • 2 hari lalu',
                            style:
                                TextStyle(fontSize: 11, color: GT.muted)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _snack('Sesi Chrome Mac OS dikeluarkan'),
                    child: const GTChip('Keluar', bg: GT.soft, fg: GT.ink),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: () => _snack(
                      'Berhasil keluar dari semua perangkat lain'),
                  icon: const Icon(Icons.logout, size: 16, color: GT.teal),
                  label: const Text('Keluar dari Semua Perangkat Lain',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: GT.teal)),
                ),
              ),
            ]),
          ),
          GTCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: const [
                Icon(Icons.warning_amber_rounded, color: GT.red),
                SizedBox(width: 8),
                Text('Zona Berisiko',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: GT.red)),
              ]),
              const SizedBox(height: 8),
              const Text(
                  'Menghapus akun akan membatalkan semua e-tiket mendatang, poin loyalitas, dan riwayat pesanan secara permanen.',
                  style: TextStyle(fontSize: 12, height: 1.4, color: GT.body)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirm2(
                      'Hapus Akun Permanen?',
                      'Tindakan ini tidak dapat dibatalkan. Semua e-tiket, poin, dan riwayat pesanan akan hilang.',
                      'Hapus Akun',
                      () => _snack('Permintaan hapus akun dikirim')),
                  icon: const Icon(Icons.delete_forever_outlined,
                      color: GT.red, size: 18),
                  label: const Text('Hapus Akun Permanen',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: GT.red)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _header(IconData i, String t, String s) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(children: [
          CircleAvatar(
              radius: 20,
              backgroundColor: GT.soft,
              child: Icon(i, color: GT.teal, size: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: GT.ink)),
                Text(s,
                    style: const TextStyle(fontSize: 11, color: GT.muted)),
              ],
            ),
          ),
        ]),
      );

  Widget _pw(String label, String hint, TextEditingController c, bool hide,
      VoidCallback toggle,
      {ValueChanged<String>? onChanged}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: GT.ink)),
      const SizedBox(height: 6),
      TextField(
        controller: c,
        obscureText: hide,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: IconButton(
            icon: Icon(
                hide ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: GT.muted),
            onPressed: toggle,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
        ),
      ),
    ]);
  }

  Widget _crit(String t, bool ok) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(children: [
          Icon(ok ? Icons.check_circle : Icons.check_circle_outline,
              size: 16, color: ok ? GT.green : GT.muted),
          const SizedBox(width: 6),
          Text(t, style: const TextStyle(fontSize: 12, color: GT.body)),
        ]),
      );

  Widget _toggle(IconData i, String t, String s, bool v, ValueChanged<bool> c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: GT.soft.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Icon(i, color: GT.teal),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: GT.ink)),
              Text(s, style: const TextStyle(fontSize: 11, color: GT.muted)),
            ],
          ),
        ),
        Switch(
          value: v,
          activeColor: Colors.white,
          activeTrackColor: GT.primary,
          onChanged: c,
        ),
      ]),
    );
  }
}
