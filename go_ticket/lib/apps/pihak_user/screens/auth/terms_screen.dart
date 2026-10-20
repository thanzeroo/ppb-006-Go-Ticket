import 'package:flutter/material.dart';

import '../../widgets/gt_ui.dart';

/// Syarat & Ketentuan + Kebijakan Hotel (Figma: "TERM & POLICIES").
///
/// Mengembalikan `true` (Setuju & Lanjutkan) atau `false` (Tolak) lewat
/// Navigator.pop.
class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _agree = true;

  static const _terms = [
    ['Check-in dan Check-out',
      'Tamu wajib mengikuti waktu check-in dan check-out yang telah ditentukan oleh pihak hotel.'],
    ['Pemesanan Kamar',
      'Setiap pemesanan harus menggunakan data tamu yang benar dan lengkap.'],
    ['Pembayaran',
      'Tamu wajib menyelesaikan pembayaran sesuai dengan metode dan ketentuan yang berlaku.'],
    ['Pembatalan Reservasi',
      'Pembatalan dan pengembalian dana mengikuti kebijakan pembatalan yang ditetapkan oleh pihak hotel.'],
    ['Kerusakan Fasilitas',
      'Tamu bertanggung jawab atas kerusakan fasilitas hotel yang disebabkan oleh kelalaian atau tindakan tamu.'],
    ['Persetujuan Ketentuan',
      'Dengan melakukan pemesanan, tamu dianggap telah membaca dan menyetujui syarat dan ketentuan hotel.'],
  ];

  static const _policies = [
    ['Kebijakan Merokok',
      'Tamu hanya diperbolehkan merokok di area yang telah disediakan oleh pihak hotel.'],
    ['Kebijakan Hewan Peliharaan',
      'Hewan peliharaan hanya diperbolehkan sesuai dengan kebijakan masing-masing hotel.'],
    ['Kebijakan Anak-anak',
      'Tamu yang membawa anak-anak wajib mengikuti ketentuan kapasitas kamar dan fasilitas tambahan yang tersedia.'],
    ['Penggunaan Fasilitas',
      'Seluruh fasilitas hotel harus digunakan sesuai dengan aturan dan jam operasional yang berlaku.'],
    ['Keamanan dan Ketertiban',
      'Tamu wajib menjaga keamanan, kebersihan, dan ketertiban selama menginap.'],
    ['Barang Hilang atau Rusak',
      'Tamu diharapkan segera melaporkan kehilangan atau kerusakan barang kepada petugas hotel.'],
    ['Perubahan Kebijakan',
      'Pihak hotel berhak memperbarui kebijakan sesuai kebutuhan operasional dengan memberikan informasi kepada tamu.'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GT.bg,
      appBar: const GTAppBar(title: 'Go Ticket', showBack: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
        children: [
          Row(children: [
            InkWell(
              onTap: () => Navigator.of(context).pop(false),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: GT.soft)),
                child: const Icon(Icons.chevron_left_rounded, color: GT.ink),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Syarat & Ketentuan',
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: GT.ink)),
            ),
            const GTChip('Hotel Policies', bg: GT.sky),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: GT.sky.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: GT.sky)),
            child: Row(children: const [
              Icon(Icons.verified_user_outlined, color: GT.teal, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text('Kebijakan Berlaku Aktif',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: GT.ink)),
              ),
              Text('Update Terakhir: 2025',
                  style: TextStyle(fontSize: 11, color: GT.muted)),
            ]),
          ),
          const SizedBox(height: 14),
          _section(
            icon: Icons.description_outlined,
            kicker: 'TERMS & CONDITIONS',
            title: 'Syarat dan Ketentuan Hotel',
            count: '${_terms.length} Butir',
            items: _terms,
            numbered: true,
          ),
          _section(
            icon: Icons.apartment_rounded,
            kicker: 'HOTEL POLICIES',
            title: 'Kebijakan Hotel',
            count: '${_policies.length} Aturan',
            items: _policies,
            numbered: false,
          ),
        ],
      ),
      bottomNavigationBar: GTBottomBar(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          GestureDetector(
            onTap: () => setState(() => _agree = !_agree),
            behavior: HitTestBehavior.opaque,
            child: Row(children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _agree ? GT.primary : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: GT.primary, width: 1.5),
                ),
                child: _agree
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 11, color: GT.body, height: 1.4),
                    children: [
                      TextSpan(
                          text:
                              'Saya telah membaca, memahami, dan menyetujui seluruh '),
                      TextSpan(
                          text: 'Syarat & Ketentuan',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, color: GT.ink)),
                      TextSpan(text: ' serta '),
                      TextSpan(
                          text: 'Kebijakan Privasi',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, color: GT.ink)),
                      TextSpan(text: ' Go Ticket.'),
                    ],
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              flex: 2,
              child: GTButton(
                label: 'Tolak',
                color: GT.soft,
                textColor: GT.ink,
                onTap: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: GTButton(
                label: 'Setuju & Lanjutkan',
                trailing: Icons.arrow_forward_rounded,
                onTap: _agree ? () => Navigator.of(context).pop(true) : null,
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String kicker,
    required String title,
    required String count,
    required List<List<String>> items,
    required bool numbered,
  }) {
    return GTCard(
      child: Column(children: [
        Row(children: [
          CircleAvatar(
              radius: 20,
              backgroundColor: GT.sky,
              child: Icon(icon, color: GT.teal, size: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kicker,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: GT.teal)),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: GT.ink)),
              ],
            ),
          ),
          GTChip(count, bg: GT.soft, fg: GT.muted),
        ]),
        const Divider(height: 24),
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                      color: numbered ? GT.sky : GT.soft,
                      shape: BoxShape.circle),
                  child: Center(
                    child: numbered
                        ? Text('${i + 1}',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: GT.teal))
                        : const Icon(Icons.check, size: 13, color: GT.teal),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                          fontSize: 13, height: 1.5, color: GT.body),
                      children: [
                        TextSpan(
                            text: '${items[i][0]}: ',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, color: GT.ink)),
                        TextSpan(text: items[i][1]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ]),
    );
  }
}
