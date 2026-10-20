import 'package:flutter/material.dart';

import '../../data/booking_args.dart';
import '../../widgets/gt_ui.dart';

/// Ulasan hotel (Figma: "USER Page Ulasan Hotel").
class HotelReviewsScreen extends StatelessWidget {
  final dynamic arguments;
  const HotelReviewsScreen({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    final a = BookingArgs.fromHotel(arguments);
    const bars = [
      ['Kebersihan', 4.9],
      ['Kenyamanan', 5.0],
      ['Pelayanan Staf', 4.8],
      ['Lokasi', 4.9],
      ['Fasilitas', 4.7],
    ];
    return Scaffold(
      backgroundColor: GT.bg,
      appBar: const GTAppBar(title: 'Hotel Reviews'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          GTCard(
            child: Row(children: [
              const CircleAvatar(
                  radius: 22,
                  backgroundColor: GT.sky,
                  child: Icon(Icons.apartment_rounded, color: GT.teal)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PROPERTI AKTIF',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: GT.teal)),
                    Text(a.hotelName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, color: GT.ink)),
                    Text(a.location,
                        style: const TextStyle(
                            fontSize: 11, color: GT.muted)),
                  ],
                ),
              ),
              GTChip('Ganti', icon: Icons.swap_horiz_rounded, bg: GT.sky),
            ]),
          ),
          GTCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text('4.9',
                                style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    color: GT.ink)),
                            Text(' / 5.0',
                                style: TextStyle(
                                    fontSize: 16, color: GT.muted)),
                          ],
                        ),
                        Row(children: [
                          for (var i = 0; i < 5; i++)
                            const Icon(Icons.star_rounded,
                                color: GT.primary, size: 20),
                        ]),
                        const SizedBox(height: 4),
                        const Text('1.280 Ulasan Terverifikasi',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: GT.body)),
                      ],
                    ),
                  ),
                  Container(
                    width: 130,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: GT.soft,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(children: const [
                      CircleAvatar(
                          radius: 16,
                          backgroundColor: GT.sky,
                          child: Icon(Icons.verified_rounded,
                              size: 18, color: GT.teal)),
                      SizedBox(height: 6),
                      Text('98% Tamu Suka & Merekomendasikan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: GT.teal)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 14),
                for (final b in bars)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(children: [
                      Row(children: [
                        Text(b[0] as String,
                            style: const TextStyle(
                                fontSize: 13, color: GT.body)),
                        const Spacer(),
                        Text((b[1] as double).toStringAsFixed(1),
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: GT.ink)),
                      ]),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (b[1] as double) / 5,
                          minHeight: 8,
                          backgroundColor: GT.soft,
                          color: GT.primary,
                        ),
                      ),
                    ]),
                  ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: const [
              GTChip('Semua (1.280)',
                  icon: Icons.check, bg: GT.primary, fg: GT.ink),
              SizedBox(width: 8),
              GTChip('Dengan Foto (420)',
                  icon: Icons.photo_camera_outlined, bg: Colors.white),
              SizedBox(width: 8),
              GTChip('Bintang 5',
                  icon: Icons.star_rounded, bg: Colors.white),
              SizedBox(width: 8),
              GTChip('Bintang 4', icon: Icons.star_rounded, bg: Colors.white),
            ]),
          ),
          const SizedBox(height: 14),
          const _ReviewItem(
            ini: 'BS',
            name: 'Budi Santoso',
            badge: 'Tamu Terverifikasi (Booking via Go Ticket)',
            stars: 5,
            score: '5.0',
            ago: '3 hari yang lalu',
            stay: 'Menginap 2 malam di Deluxe Ocean View',
            text:
                'Pengalaman luar biasa! Kolam renang dengan pemandangan sunset '
                'sangat magis. Resepsionis dan staf sangat ramah, check-in hanya '
                'butuh tunjukkan QR Go Ticket.',
            reply:
                'Terima kasih Bpk. Budi, senang bisa melayani Anda! Kami tunggu '
                'kedatangan Anda kembali di liburan berikutnya.',
            helpful: 24,
            hasPhotos: true,
          ),
          const _ReviewItem(
            ini: 'JT',
            name: 'Jessica Tan',
            badge: 'Tamu Terverifikasi',
            stars: 5,
            score: '5.0',
            ago: '1 minggu yang lalu',
            stay: 'Staycation Pasangan • Suite King Garden',
            text:
                'Sarapan prasmanan lezat sekali, kasur super empuk dan bersih '
                'tanpa cela. Pasti akan pesan lagi lewat Go Ticket!',
            helpful: 18,
          ),
          const _ReviewItem(
            ini: 'DA',
            name: 'Dimas Arya',
            badge: 'Tamu Terverifikasi',
            stars: 4,
            score: '4.8',
            ago: '2 minggu yang lalu',
            stay: 'Liburan Keluarga • Villa 2 Kamar dengan Kolam Privat',
            text:
                'Villa sangat luas dan nyaman untuk anak-anak. Layanan butler '
                '24 jam sangat membantu saat butuh tambahan handuk.',
            helpful: 9,
          ),
        ],
      ),
      bottomNavigationBar: GTBottomBar(
        child: GTButton(
          label: 'Tulis Ulasan Penginapan Saya',
          leading: Icons.star_rounded,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Ulasan hanya bisa ditulis setelah selesai menginap')),
          ),
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String ini, name, badge, score, ago, stay, text;
  final String? reply;
  final int stars;
  final int helpful;
  final bool hasPhotos;
  const _ReviewItem({
    required this.ini,
    required this.name,
    required this.badge,
    required this.stars,
    required this.score,
    required this.ago,
    required this.stay,
    required this.text,
    required this.helpful,
    this.reply,
    this.hasPhotos = false,
  });

  @override
  Widget build(BuildContext context) {
    return GTCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
                radius: 20,
                backgroundColor: GT.sky,
                child: Text(ini,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: GT.ink))),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: GT.ink)),
                  const SizedBox(height: 4),
                  GTChip(badge,
                      icon: Icons.verified_outlined, bg: GT.sky),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            for (var i = 0; i < 5; i++)
              Icon(i < stars ? Icons.star_rounded : Icons.star_half_rounded,
                  size: 17, color: GT.primary),
            const SizedBox(width: 6),
            Text(score,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: GT.ink)),
            const Spacer(),
            Text(ago,
                style: const TextStyle(fontSize: 11, color: GT.muted)),
          ]),
          const SizedBox(height: 6),
          Text(stay,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: GT.teal)),
          const SizedBox(height: 8),
          Text(text,
              style: const TextStyle(
                  fontSize: 13, height: 1.5, color: GT.body)),
          if (hasPhotos) ...[
            const SizedBox(height: 10),
            Row(children: const [
              Expanded(
                  child: GTImage(
                      'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=400',
                      height: 90,
                      radius: 12)),
              SizedBox(width: 8),
              Expanded(
                  child: GTImage(
                      'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=400',
                      height: 90,
                      radius: 12)),
            ]),
          ],
          if (reply != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: GT.soft, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tanggapan dari Manajemen The Grand Amora',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: GT.teal)),
                  const SizedBox(height: 4),
                  Text(reply!,
                      style: const TextStyle(
                          fontSize: 12, height: 1.4, color: GT.body)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(children: [
            GTChip('Membantu ($helpful)',
                icon: Icons.thumb_up_alt_outlined, bg: GT.soft),
            const Spacer(),
            const Icon(Icons.share_outlined, size: 16, color: GT.muted),
            const SizedBox(width: 4),
            const Text('Bagikan',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: GT.ink)),
          ]),
        ],
      ),
    );
  }
}
