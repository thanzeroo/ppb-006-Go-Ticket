import 'package:flutter/material.dart';

import 'package:go_ticket/core/models/booking_args.dart';
import 'package:go_ticket/core/models/review_model.dart';
import 'package:go_ticket/core/services/review_service.dart';
import 'package:go_ticket/core/widgets/gt_ui.dart';

/// Ulasan hotel (Figma: "USER Page Ulasan Hotel").
/// Menampilkan data ulasan dinamis dari DB; jika kosong → empty state.
class HotelReviewsScreen extends StatefulWidget {
  final dynamic arguments;
  const HotelReviewsScreen({super.key, this.arguments});

  @override
  State<HotelReviewsScreen> createState() => _HotelReviewsScreenState();
}

class _HotelReviewsScreenState extends State<HotelReviewsScreen> {
  late final BookingArgs _a;
  List<ReviewModel> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _a = BookingArgs.fromHotel(widget.arguments);
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviews =
        await ReviewService.instance.getReviewsByHotel(_a.hotelId);
    if (mounted) {
      setState(() {
        _reviews = reviews;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GT.bg,
      appBar: const GTAppBar(title: 'Ulasan Hotel'),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: GT.teal))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    // ─── Hitung rata-rata dari data nyata ───────────────────────────────────
    final count = _reviews.length;
    final avg = count == 0
        ? 0.0
        : _reviews.fold<double>(0, (s, r) => s + r.overallRating) / count;
    final avgStr = avg == 0 ? '–' : avg.toStringAsFixed(1);

    // ─── Rata-rata per kategori ─────────────────────────────────────────────
    double _catAvg(Iterable<int?> vals) {
      final v = vals.whereType<int>().toList();
      if (v.isEmpty) return 0;
      return v.fold<int>(0, (s, x) => s + x) / v.length;
    }

    final catCleanliness = _catAvg(_reviews.map((r) => r.cleanlinessRating));
    final catComfort =
        _catAvg(_reviews.map((r) => r.valueRating)); // nilai/kenyamanan
    final catService = _catAvg(_reviews.map((r) => r.serviceRating));
    final catLocation = _catAvg(_reviews.map((r) => r.locationRating));
    final catFacility = _catAvg(_reviews.map((r) => r.facilityRating));

    final bars = [
      ['Kebersihan', catCleanliness],
      ['Kenyamanan', catComfort],
      ['Pelayanan Staf', catService],
      ['Lokasi', catLocation],
      ['Fasilitas', catFacility],
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      children: [
        // ── Info properti ──────────────────────────────────────────────────
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
                  Text(_a.hotelName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, color: GT.ink)),
                  Text(_a.location,
                      style:
                          const TextStyle(fontSize: 11, color: GT.muted)),
                ],
              ),
            ),
          ]),
        ),

        // ── Ringkasan rating ───────────────────────────────────────────────
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
                        children: [
                          Text(avgStr,
                              style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: GT.ink)),
                          const Text(' / 5.0',
                              style: TextStyle(
                                  fontSize: 16, color: GT.muted)),
                        ],
                      ),
                      Row(children: [
                        for (var i = 0; i < 5; i++)
                          Icon(
                            i < avg.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: GT.primary,
                            size: 20,
                          ),
                      ]),
                      const SizedBox(height: 4),
                      Text(
                          count == 0
                              ? 'Belum ada ulasan'
                              : '$count Ulasan Terverifikasi',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: GT.body)),
                    ],
                  ),
                ),
                if (count > 0)
                  Container(
                    width: 130,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: GT.soft,
                        borderRadius: BorderRadius.circular(16)),
                    child: const Column(children: [
                      CircleAvatar(
                          radius: 16,
                          backgroundColor: GT.sky,
                          child: Icon(Icons.verified_rounded,
                              size: 18, color: GT.teal)),
                      SizedBox(height: 6),
                      Text('Ulasan dari tamu yang sudah menginap',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: GT.teal)),
                    ]),
                  ),
              ]),
              if (count > 0) ...[
                const SizedBox(height: 14),
                for (final b in bars)
                  if ((b[1] as double) > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _RatingBar(
                        label: b[0] as String,
                        value: (b[1] as double) / 5.0,
                        score: (b[1] as double).toStringAsFixed(1),
                      ),
                    ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 4),

        // ── Empty state ────────────────────────────────────────────────────
        if (count == 0) ...[
          const SizedBox(height: 40),
          const Center(
            child: Column(children: [
              Icon(Icons.rate_review_outlined, size: 56, color: GT.muted),
              SizedBox(height: 12),
              Text('Belum Ada Ulasan',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: GT.ink)),
              SizedBox(height: 6),
              Text('Jadilah yang pertama memberikan ulasan\nsetelah menginap di hotel ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: GT.muted)),
            ]),
          ),
          const SizedBox(height: 40),
        ],

        // ── Daftar ulasan dari DB ──────────────────────────────────────────
        for (final r in _reviews) _buildReviewCard(r),

        const SizedBox(height: 8),
        GTButton(
          label: 'Tulis Ulasan Penginapan Saya',
          leading: Icons.star_rounded,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Ulasan hanya bisa ditulis setelah selesai menginap')),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(ReviewModel r) {
    final starsInt = r.overallRating.round().clamp(1, 5);
    final ago = _timeAgo(r.createdAt);
    final stayInfo = r.roomTypeName != null
        ? 'Menginap di ${r.roomTypeName}'
        : 'Tamu Terverifikasi';

    return GTCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
                radius: 20,
                backgroundColor: GT.sky,
                child: Text(r.customerInitials,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: GT.ink))),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.customerName,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: GT.ink)),
                  const SizedBox(height: 4),
                  GTChip('Tamu Terverifikasi (Booking via Go Ticket)',
                      icon: Icons.verified_outlined, bg: GT.sky),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            for (var i = 0; i < 5; i++)
              Icon(
                i < starsInt
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 17,
                color: GT.primary,
              ),
            const SizedBox(width: 6),
            Text(r.overallRating.toStringAsFixed(1),
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: GT.ink)),
            const Spacer(),
            Text(ago,
                style: const TextStyle(fontSize: 11, color: GT.muted)),
          ]),
          const SizedBox(height: 6),
          Text(stayInfo,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: GT.teal)),
          if (r.reviewText != null && r.reviewText!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(r.reviewText!,
                style: const TextStyle(
                    fontSize: 13, height: 1.5, color: GT.body)),
          ],
          if (r.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: r.photoUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) =>
                    GTImage(r.photoUrls[i], height: 90, radius: 12),
              ),
            ),
          ],
          if (r.hotelResponse != null && r.hotelResponse!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: GT.soft,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tanggapan dari Manajemen Hotel',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: GT.teal)),
                  const SizedBox(height: 4),
                  Text(r.hotelResponse!,
                      style: const TextStyle(
                          fontSize: 12, height: 1.4, color: GT.body)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 30) return '${diff.inDays ~/ 30} bulan yang lalu';
    if (diff.inDays >= 7) return '${diff.inDays ~/ 7} minggu yang lalu';
    if (diff.inDays >= 1) return '${diff.inDays} hari yang lalu';
    if (diff.inHours >= 1) return '${diff.inHours} jam yang lalu';
    return 'Baru saja';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RATING BAR WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _RatingBar extends StatelessWidget {
  final String label;
  final double value; // 0.0–1.0
  final String score;

  const _RatingBar(
      {required this.label, required this.value, required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 110,
        child: Text(label,
            style:
                const TextStyle(fontSize: 12, color: GT.body)),
      ),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: GT.soft,
            valueColor: const AlwaysStoppedAnimation<Color>(GT.teal),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text(score,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: GT.ink)),
    ]);
  }
}
