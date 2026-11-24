import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:go_ticket_user/core/services/supabase_service.dart';
import 'package:go_ticket_user/core/widgets/gt_ui.dart';

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

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m)));

  Future<void> _updatePassword() async {
    if (_old.text.isEmpty) return _snack('Masukkan kata sandi saat ini');
    if (_new.text.length < 8) {
      return _snack('Kata sandi baru minimal 8 karakter');
    }
    if (_new.text != _confirm.text) {
      return _snack('Konfirmasi kata sandi tidak sama');
    }

    try {
      final client = SupabaseService.instance.client;
      if (client != null) {
        await client.auth.updateUser(
          UserAttributes(password: _new.text.trim()),
        );
      }
      if (!mounted) return;
      setState(() {
        _old.clear();
        _new.clear();
        _confirm.clear();
      });
      _snack('Kata sandi berhasil diperbarui');
    } catch (e) {
      if (!mounted) return;
      _snack('Gagal memperbarui kata sandi: $e');
    }
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
    return Scaffold(
      backgroundColor: GT.bg,
      appBar: const GTAppBar(title: 'Keamanan Akun'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GTCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: GT.sky,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: GT.teal,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Ubah Kata Sandi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: GT.ink,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _pw('Kata Sandi Saat Ini', 'Masukkan kata sandi lama', _old,
                          _hideOld, () => setState(() => _hideOld = !_hideOld)),
                      const SizedBox(height: 12),
                      _pw('Kata Sandi Baru', 'Buat kata sandi baru (min. 8 karakter)', _new, _hideNew,
                          () => setState(() => _hideNew = !_hideNew),
                          onChanged: (_) => setState(() {})),
                      const SizedBox(height: 12),
                      _pw('Konfirmasi Kata Sandi Baru', 'Ulangi kata sandi baru',
                          _confirm, _hideConfirm,
                          () => setState(() => _hideConfirm = !_hideConfirm)),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: GTButton(
                          label: 'Perbarui Kata Sandi',
                          leading: Icons.vpn_key_outlined,
                          onTap: _updatePassword,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                GTCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: GT.red),
                          SizedBox(width: 8),
                          Text('Zona Berisiko',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: GT.red)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Menghapus akun akan membatalkan semua e-tiket dan riwayat pesanan secara permanen.',
                        style: TextStyle(fontSize: 12, height: 1.4, color: GT.body),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _confirm2(
                            'Hapus Akun Permanen?',
                            'Tindakan ini tidak dapat dibatalkan. Semua e-tiket dan riwayat pesanan akan hilang.',
                            'Hapus Akun',
                            () => _snack('Permintaan hapus akun dikirim'),
                          ),
                          icon: const Icon(Icons.delete_forever_outlined,
                              color: GT.red, size: 18),
                          label: const Text('Hapus Akun Permanen',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, color: GT.red)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
}
