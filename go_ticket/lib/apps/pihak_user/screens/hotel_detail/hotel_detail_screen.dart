import 'package:flutter/material.dart';

import 'package:go_ticket/core/models/booking_args.dart';
import 'package:go_ticket/core/models/review_model.dart';
import 'package:go_ticket/core/services/customer_data_service.dart';
import 'package:go_ticket/core/services/review_service.dart';
import '../../router/customer_router.dart';
import 'package:go_ticket/core/widgets/gt_ui.dart';
import '../../services/user_booking_storage.dart';

/// Detail hotel (Figma: "USER Page Hotel").
class HotelDetailScreen extends StatefulWidget {
  /// Map hotel dari tab Beranda/Cari/Tersimpan, atau BookingArgs.
  final dynamic arguments;
  const HotelDetailScreen({super.key, this.arguments});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  late final BookingArgs _args = BookingArgs.fromHotel(widget.arguments);
  bool _fav = false;
  List<ReviewModel> _reviews = [];
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _checkSavedAndLoadReviews();
  }

  Future<void> _checkSavedAndLoadReviews() async {
    final isSaved =
        await CustomerDataService.instance.isHotelSaved(_args.hotelId);
    final remoteReviews =
        await ReviewService.instance.getReviewsByHotel(_args.hotelId);
    final localReviews =
        await UserBookingStorage.instance.getReviewsByHotel(_args.hotelId);

    final Map<String, ReviewModel> reviewMap = {};
    for (final r in localReviews) {
      reviewMap[r.id] = r;
    }
    for (final r in remoteReviews) {
      if (!reviewMap.containsKey(r.id)) {
        reviewMap[r.id] = r;
      }
    }

    if (mounted) {
      setState(() {
        _fav = isSaved;
        _reviews = reviewMap.values.toList();
        _loadingReviews = false;
      });
    }
  }

  List<String> get _galleryPhotos {
    final list = <String>[];
    if (_args.imageUrl.isNotEmpty) list.add(_args.imageUrl);
    list.addAll(_thumbs);
    const extras = [
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=900',
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=900',
      'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=900',
      'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=900',
    ];
    for (final e in extras) {
      if (!list.contains(e)) list.add(e);
    }
    return list;
  }

  void _openPhotoGallery(int initialIndex) {
    final photos = _galleryPhotos;
    final index = initialIndex.clamp(0, photos.length - 1);
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.94),
        pageBuilder: (context, _, __) => _PhotoGalleryScreen(
          photos: photos,
          initialIndex: index,
          title: _args.hotelName,
        ),
      ),
    );
  }

  Future<void> _toggleFav() async {
    final hotelMap = {
      'id': _args.hotelId,
      'name': _args.hotelName,
      'location': _args.location,
      'priceValue': _args.roomPrice,
      'imageUrl': _args.imageUrl,
      'type': 'Resor • ⭐ 5',
    };
    final isSaved =
        await CustomerDataService.instance.toggleSavedHotel(hotelMap);
    if (mounted) {
      setState(() => _fav = isSaved);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSaved
              ? '${_args.hotelName} disimpan ke favorit'
              : '${_args.hotelName} dihapus dari favorit'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  static const _thumbs = [
    'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=300',
    'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=300',
    'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=300',
  ];

  void _toRooms() => Navigator.pushNamed(
        context,
        CustomerRouter.roomSelection,
        arguments: _args,
      );

  void _toReviews() => Navigator.pushNamed(
        context,
        CustomerRouter.hotelReviews,
        arguments: _args,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GT.bg,
      appBar: const GTAppBar(title: 'Property Detail'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          _hero(),
          const SizedBox(height: 10),
          _thumbRow(),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: const [
            GTChip('RESOR PILIHAN • BINTANG 5',
                icon: Icons.workspace_premium_rounded,
                bg: GT.sky),
            GTChip('Terverifikasi Go Ticket',
                icon: Icons.verified_outlined, bg: Colors.white),
          ]),
          const SizedBox(height: 10),
          Text(
            _args.hotelName,
            style: const TextStyle(
                fontSize: 26,
                height: 1.15,
                fontWeight: FontWeight.w800,
                color: GT.ink),
          ),
          const SizedBox(height: 14),
          _ratingCard(),
          const SizedBox(height: 22),
          _sectionTitle('Fasilitas Unggulan'),
          _facilities(),
          const SizedBox(height: 22),
          _sectionTitle('Lokasi Penginapan'),
          _mapCard(),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _sectionTitle('Ulasan Tamu Pilihan',
                    sub: 'Kepuasan asli dari pengalaman menginap'),
              ),
              GestureDetector(
                onTap: _toReviews,
                child: GTChip(
                    _reviews.isNotEmpty
                        ? '${_reviews.length} Ulasan'
                        : 'Belum Ada',
                    bg: GT.sky,
                    fg: GT.teal),
              ),
            ],
          ),
          if (_loadingReviews)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                  child: CircularProgressIndicator(
                      color: GT.teal, strokeWidth: 2)),
            )
          else if (_reviews.isEmpty)
            GTCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: GT.sky,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.rate_review_outlined,
                        color: GT.teal, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Belum Ada Ulasan',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, color: GT.ink)),
                        SizedBox(height: 2),
                        Text(
                            'Jadilah tamu pertama yang memberikan ulasan setelah check-out.',
                            style: TextStyle(fontSize: 12, color: GT.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else ...[
            for (final r in _reviews.take(2))
              _review(
                (r.authorName.isNotEmpty
                    ? r.authorName.substring(0, 1).toUpperCase()
                    : 'G'),
                r.authorName.isNotEmpty ? r.authorName : 'Tamu Go Ticket',
                r.formattedDate.isNotEmpty
                    ? r.formattedDate
                    : 'Ulasan Terverifikasi',
                r.overallRating.round(),
                '“${r.comment}”',
                const ['Ulasan Nyata Terverifikasi'],
              ),
            Center(
              child: TextButton(
                onPressed: _toReviews,
                child: Text('Lihat semua ${_reviews.length} ulasan',
                    style: const TextStyle(
                        color: GT.teal, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
          const SizedBox(height: 10),
          _sectionTitle('Kebijakan Menginap',
              sub: 'Ketentuan penting untuk kenyamanan bersama'),
          _policyCard(),
        ],
      ),
      bottomNavigationBar: GTBottomBar(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('MULAI DARI',
                        style: TextStyle(
                            fontSize: 10,
                            color: GT.muted,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    if (_args.originalPrice != null &&
                        _args.originalPrice! > _args.roomPrice)
                      GTChip(
                        'Hemat ${((_args.originalPrice! - _args.roomPrice) *
                                    100 /
                                    _args.originalPrice!)
                                .round()}%',
                        bg: Color(0xFFFEE2E2),
                        fg: GT.red,
                      ),
                  ]),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(rp(_args.roomPrice),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: GT.teal)),
                      const Text('/mlm',
                          style: TextStyle(fontSize: 12, color: GT.muted)),
                    ],
                  ),
                ],
              ),
            ),
            GTButton(
              label: 'Pilih Tipe Kamar',
              trailing: Icons.arrow_forward_rounded,
              onTap: _toRooms,
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _openPhotoGallery(0),
          child: GTImage(
            _args.imageUrl,
            height: 230,
            width: double.infinity,
            radius: 24,
          ),
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: _overlayChip(Icons.circle, 'Resor Tepi Pantai', small: true),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: GestureDetector(
            onTap: () => _openPhotoGallery(0),
            child: _overlayChip(
              Icons.photo_library_outlined,
              '+12 Foto',
              dark: true,
            ),
          ),
        ),
        Positioned(
          right: 12,
          top: 12,
          child: GestureDetector(
            onTap: _toggleFav,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(
                _fav ? Icons.favorite : Icons.favorite_border,
                color: _fav ? Colors.red : GT.red,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _overlayChip(IconData icon, String text,
      {bool dark = false, bool small = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: dark ? const Color(0xCC1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon,
            size: small ? 8 : 15, color: dark ? Colors.white : GT.primary),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: dark ? Colors.white : GT.ink)),
      ]),
    );
  }

  Widget _thumbRow() {
    return Row(
      children: [
        for (var i = 0; i < _thumbs.length; i++) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => _openPhotoGallery(i + 1),
              child: GTImage(_thumbs[i], height: 62, radius: 12),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: GestureDetector(
            onTap: () => _openPhotoGallery(1),
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: GT.soft,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                '+9 Lagi',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: GT.teal,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _ratingCard() {
    return GTCard(
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: GT.teal, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              Text(_args.rating,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const Text('/5.0',
                  style: TextStyle(color: Colors.white70, fontSize: 10)),
            ]),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Luar Biasa ',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: GT.ink)),
                  Icon(Icons.star_rounded, color: GT.primary, size: 18),
                ]),
                Text('Dari 340 ulasan tamu asli',
                    style: TextStyle(fontSize: 12, color: GT.muted)),
              ],
            ),
          ),
          SizedBox(
            width: 72,
            height: 28,
            child: Stack(children: [
              for (var i = 0; i < 3; i++)
                Positioned(
                  left: i * 18.0,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: i == 2 ? GT.soft : GT.sky,
                    child: Text(['A', 'M', '+3'][i],
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: GT.teal)),
                  ),
                ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t, {String? sub}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: GT.ink)),
          if (sub != null)
            Text(sub,
                style: const TextStyle(fontSize: 12, color: GT.muted)),
        ],
      ),
    );
  }

  Widget _facilities() {
    Widget tile(IconData i, String t, String s) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                    radius: 18,
                    backgroundColor: GT.soft,
                    child: Icon(i, color: GT.teal, size: 18)),
                const SizedBox(height: 10),
                Text(t,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: GT.ink)),
                Text(s,
                    style: const TextStyle(fontSize: 11, color: GT.muted)),
              ],
            ),
          ),
        );
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(children: const [
          CircleAvatar(
              radius: 22,
              backgroundColor: GT.sky,
              child: Icon(Icons.pool_rounded, color: GT.teal)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Infinity Pool Tepi Pantai',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: GT.ink)),
                Text('Pemandangan sunset eksotis tanpa batas',
                    style: TextStyle(fontSize: 11, color: GT.muted)),
              ],
            ),
          ),
          Icon(Icons.wb_sunny_outlined, color: GT.primary),
        ]),
      ),
      const SizedBox(height: 10),
      Row(children: [
        tile(Icons.restaurant_rounded, 'Restoran & Buffet VIP',
            'Sarapan kontinental'),
        const SizedBox(width: 10),
        tile(Icons.spa_outlined, 'Spa & Wellness', 'Aromaterapi Bali'),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        tile(Icons.wifi_rounded, 'WiFi 100 Mbps', 'Stabil di seluruh area'),
        const SizedBox(width: 10),
        tile(Icons.support_agent_rounded, 'Resepsionis 24 Jam',
            'Layanan concierge'),
      ]),
    ]);
  }

  Widget _mapCard() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F1E8), Color(0xFFD7ECF5)],
        ),
      ),
      child: Stack(children: [
        const Positioned(
          right: 24,
          top: 18,
          child: Icon(Icons.map_outlined, size: 70, color: Colors.white70),
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22)),
            child: Row(children: const [
              CircleAvatar(
                  radius: 14,
                  backgroundColor: GT.sky,
                  child: Icon(Icons.location_on, size: 16, color: GT.teal)),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Seminyak, Bali',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: GT.ink)),
                  Text('300m dari Pantai Kayu Aya',
                      style: TextStyle(fontSize: 10, color: GT.muted)),
                ],
              ),
            ]),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Peta segera hadir'))),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16)),
              child: const Text('Buka Peta',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: GT.teal)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _review(String ini, String name, String meta, int stars,
      String text, List<String> tags) {
    return GTCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
                radius: 18,
                backgroundColor: GT.sky,
                child: Text(ini,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: GT.teal))),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: GT.ink)),
                  Text(meta,
                      style:
                          const TextStyle(fontSize: 11, color: GT.muted)),
                ],
              ),
            ),
            Row(children: [
              for (var i = 0; i < 5; i++)
                Icon(i < stars ? Icons.star_rounded : Icons.star_half_rounded,
                    size: 15, color: GT.primary),
            ]),
          ]),
          const SizedBox(height: 10),
          Text(text,
              style: const TextStyle(
                  fontSize: 13, height: 1.5, color: GT.body)),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 8, children: [
              for (final t in tags) GTChip(t, bg: GT.sky),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _policyCard() {
    Widget row(IconData i, String t, {Color c = GT.body}) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(children: [
            Icon(i, size: 16, color: c),
            const SizedBox(width: 8),
            Expanded(
                child: Text(t,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: GT.ink))),
          ]),
        );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: GT.sky.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18)),
      child: Column(children: [
        Row(children: const [
          Expanded(
              child: _TimeBox(Icons.login_rounded, 'CHECK-IN MULAI',
                  '14:00 WITA')),
          Expanded(
              child: _TimeBox(Icons.logout_rounded, 'CHECK-OUT MAKS',
                  '12:00 WITA')),
        ]),
        const Divider(height: 24),
        row(Icons.smoke_free_rounded, 'Bebas asap rokok di seluruh tipe kamar',
            c: GT.red),
        row(Icons.pets_rounded, 'Hewan peliharaan tidak diperkenankan',
            c: GT.teal),
        row(Icons.credit_card_rounded,
            'Deposit tunai/kartu dapat diminta saat check-in',
            c: GT.teal),
      ]),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  const _TimeBox(this.icon, this.label, this.time);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: GT.teal, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: GT.muted)),
            Text(time,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: GT.ink)),
          ],
        ),
      ],
    );
  }
}

class _PhotoGalleryScreen extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  final String title;

  const _PhotoGalleryScreen({
    required this.photos,
    required this.initialIndex,
    required this.title,
  });

  @override
  State<_PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<_PhotoGalleryScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${_currentIndex + 1} dari ${widget.photos.length} Foto',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Photo View with InteractiveViewer
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.photos.length,
                onPageChanged: (idx) => setState(() => _currentIndex = idx),
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 3.5,
                    child: Center(
                      child: Image.network(
                        widget.photos[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(color: GT.teal),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Bottom Thumbnail Strip
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.photos.length,
                itemBuilder: (context, idx) {
                  final isSelected = idx == _currentIndex;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        idx,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? GT.teal : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        widget.photos[idx],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
