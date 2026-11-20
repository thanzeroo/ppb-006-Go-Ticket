import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_ticket_user/core/widgets/app_pagination_bar.dart';
import 'package:go_ticket_user/core/services/auth_service.dart';
import 'package:go_ticket_user/core/services/customer_data_service.dart';
import 'package:go_ticket_user/core/utils/currency_formatter.dart';
import 'package:go_ticket_user/core/widgets/user_avatar.dart';
import '../../../router/customer_router.dart';
import '../customer_dashboard_screen.dart';
import 'pesanan_tab.dart';

enum _HotelSortOrder {
  recommended,
  priceLowToHigh,
  priceHighToLow,
  ratingHighToLow,
}

class _SavedHotelFilters {
  const _SavedHotelFilters({
    this.sortOrder = _HotelSortOrder.recommended,
    this.promotionsOnly = false,
    this.maxPrice = 2000000,
  });

  final _HotelSortOrder sortOrder;
  final bool promotionsOnly;
  final double maxPrice;
}

/// Tab Saved Hotel (dari halaman Pesanan → tab Saved Hotel)
class SavedHotelScreen extends StatefulWidget {
  final VoidCallback? onSwitchToPemesanan;

  const SavedHotelScreen({super.key, this.onSwitchToPemesanan});

  @override
  State<SavedHotelScreen> createState() => _SavedHotelScreenState();
}

class _SavedHotelScreenState extends State<SavedHotelScreen> {
  String _activeCategory = 'Semua';
  String? _activeFolder;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  _SavedHotelFilters _filters = const _SavedHotelFilters();
  final List<String> _categories = [
    'Semua',
    'Resor Bali',
    'Villa Privat',
    'Hotel Kota',
  ];

  final List<Map<String, dynamic>> _folders = [
    {
      'name': 'Liburan Akhir Tahun',
      'icon': Icons.wb_sunny,
      'color': Color(0xFF00B4D8),
    },
    {
      'name': 'Staycation Romantis',
      'icon': Icons.favorite,
      'color': Color(0xFFEC4899),
    },
  ];

  List<Map<String, dynamic>> _hotels = [];
  bool _isLoading = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    final list = await CustomerDataService.instance.getSavedHotels();
    if (mounted) {
      setState(() {
        _hotels = List<Map<String, dynamic>>.from(list);
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredHotels {
    final query = _searchQuery.trim().toLowerCase();
    final hotels = _hotels.where((hotel) {
      final category = hotel['category']?.toString() ?? 'Semua';
      final matchesCategory =
          _activeCategory == 'Semua' || category == _activeCategory;

      final folders = (hotel['folders'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[];
      final matchesFolder =
          _activeFolder == null || folders.contains(_activeFolder);

      final name = hotel['name']?.toString() ?? '';
      final location = hotel['location']?.toString() ?? '';
      final type = hotel['type']?.toString() ?? '';
      final searchableText = '$name $location $type'.toLowerCase();
      final matchesSearch = query.isEmpty || searchableText.contains(query);

      final priceVal = (hotel['priceValue'] as num?)?.toInt() ??
          int.tryParse(hotel['priceValue']?.toString() ?? '0') ??
          0;
      final matchesPrice = priceVal <= _filters.maxPrice;
      final matchesPromotion =
          !_filters.promotionsOnly || hotel['discount'] != null;

      return matchesCategory &&
          matchesFolder &&
          matchesSearch &&
          matchesPrice &&
          matchesPromotion;
    }).toList();

    int parsePrice(Map<String, dynamic> h) =>
        (h['priceValue'] as num?)?.toInt() ??
        int.tryParse(h['priceValue']?.toString() ?? '0') ??
        0;

    double parseRating(Map<String, dynamic> h) =>
        double.tryParse(h['rating']?.toString() ?? '0') ?? 0.0;

    switch (_filters.sortOrder) {
      case _HotelSortOrder.recommended:
        break;
      case _HotelSortOrder.priceLowToHigh:
        hotels.sort((a, b) => parsePrice(a).compareTo(parsePrice(b)));
      case _HotelSortOrder.priceHighToLow:
        hotels.sort((a, b) => parsePrice(b).compareTo(parsePrice(a)));
      case _HotelSortOrder.ratingHighToLow:
        hotels.sort((a, b) => parseRating(b).compareTo(parseRating(a)));
    }
    return hotels;
  }

  String _formatPrice(Object? value) {
    final amount = int.tryParse(
      value.toString().replaceAll(RegExp(r'[^0-9]'), ''),
    );
    return amount == null
        ? value.toString()
        : CurrencyFormatter.toRupiah(amount);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    var sortOrder = _filters.sortOrder;
    var promotionsOnly = _filters.promotionsOnly;
    var maxPrice = _filters.maxPrice;
    final result = await showModalBottomSheet<_SavedHotelFilters>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Saved Hotel',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setSheetState(() {
                        sortOrder = _HotelSortOrder.recommended;
                        promotionsOnly = false;
                        maxPrice = 2000000;
                      }),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Urutkan berdasarkan',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                for (final option in [
                  (_HotelSortOrder.recommended, 'Rekomendasi'),
                  (_HotelSortOrder.priceLowToHigh, 'Harga terendah'),
                  (_HotelSortOrder.priceHighToLow, 'Harga tertinggi'),
                  (_HotelSortOrder.ratingHighToLow, 'Rating tertinggi'),
                ])
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(option.$2),
                    trailing: Icon(
                      sortOrder == option.$1
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: sortOrder == option.$1
                          ? const Color(0xFF00B4D8)
                          : const Color(0xFF9CA3AF),
                    ),
                    onTap: () => setSheetState(() => sortOrder = option.$1),
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tampilkan hotel dengan promo saja'),
                  value: promotionsOnly,
                  activeThumbColor: const Color(0xFF00B4D8),
                  onChanged: (value) =>
                      setSheetState(() => promotionsOnly = value),
                ),
                const SizedBox(height: 8),
                Text(
                  'Harga maksimum: ${_formatPrice(maxPrice.round())}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: maxPrice,
                  min: 0,
                  max: 2000000,
                  divisions: 40,
                  label: _formatPrice(maxPrice.round()),
                  activeColor: const Color(0xFF00B4D8),
                  onChanged: (value) => setSheetState(() => maxPrice = value),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(
                      sheetContext,
                      _SavedHotelFilters(
                        sortOrder: sortOrder,
                        promotionsOnly: promotionsOnly,
                        maxPrice: maxPrice,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B4D8),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Terapkan Filter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _filters = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredHotels = _filteredHotels;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchAndFilter(),
          _buildFolderSection(),
          _buildCategoryTabs(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredHotels.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 36),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFC8F0FA),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite_border_rounded,
                                  color: Color(0xFF0077B6),
                                  size: 34,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum Ada Hotel Tersimpan',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Simpan hotel favorit Anda dengan menekan ikon hati di Beranda atau Cari untuk melihatnya di sini.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  CustomerDashboardScreen.tabNotifier.value = 1;
                                  if (widget.onSwitchToPemesanan == null &&
                                      Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00B4D8),
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22, vertical: 12),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Jelajahi Hotel Sekarang',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Builder(
                        builder: (ctx) {
                          final total = filteredHotels.length;
                          final maxPage = (total / 10).ceil();
                          final safePage = _currentPage.clamp(1, maxPage > 0 ? maxPage : 1);
                          final pagedHotels = paginateList(filteredHotels, safePage, pageSize: 10);

                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: pagedHotels.length + (total > 0 ? 1 : 0),
                            itemBuilder: (ctx, i) {
                              if (i < pagedHotels.length) {
                                return _buildHotelCard(pagedHotels[i]);
                              }
                              return AppPaginationBar(
                                currentPage: safePage,
                                totalItems: total,
                                pageSize: 10,
                                itemLabel: 'hotel tersimpan',
                                primaryColor: const Color(0xFF00B4D8),
                                onPageChanged: (p) => setState(() => _currentPage = p),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 28,
                        errorBuilder: (_, __, ___) => Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00B4D8),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                'GO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'GoTicket',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF111827),
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Saved Hotels',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      UserAvatar(
                        name: AuthService.instance.currentUser?.fullName,
                        radius: 17,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Tab switcher
              Row(
                children: [
                  _buildTopTab('Pemesanan', false),
                  const SizedBox(width: 8),
                  _buildTopTab('Saved Hotel', true),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopTab(String label, bool isSelected) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: isSelected
          ? null
          : () {
              if (widget.onSwitchToPemesanan != null) {
                widget.onSwitchToPemesanan!();
                return;
              }
              CustomerDashboardScreen.tabNotifier.value = 2;
              PesananTab.subTabNotifier.value = 0;
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  CustomerRouter.dashboard,
                  (route) => false,
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  CustomerDashboardScreen.tabNotifier.value = 2;
                  PesananTab.subTabNotifier.value = 0;
                });
              }
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00B4D8) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00B4D8)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Cari koleksi favorit...',
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Hapus pencarian',
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                icon: const Icon(Icons.close, size: 18),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Filter dan urutkan',
            onPressed: _openFilters,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF5F7FA),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(
              Icons.tune,
              color:
                  _filters.sortOrder != _HotelSortOrder.recommended ||
                      _filters.promotionsOnly ||
                      _filters.maxPrice < 2000000
                  ? const Color(0xFF00B4D8)
                  : const Color(0xFF6B7280),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderSection() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FOLDER KOLEKSI',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9CA3AF),
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  '${_hotels.length} Favorit Aktif',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF00B4D8),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: _folders.map((f) {
                final folderName = f['name'] as String;
                final folderColor = f['color'] as Color;
                final isSelected = _activeFolder == folderName;
                final count = _hotels
                    .where(
                      (hotel) => (hotel['folders'] as List<String>).contains(
                        folderName,
                      ),
                    )
                    .length;
                return GestureDetector(
                  onTap: () => setState(() {
                    _activeFolder = isSelected ? null : folderName;
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? folderColor.withValues(alpha: 0.2)
                          : folderColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: folderColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          f['icon'] as IconData,
                          color: folderColor,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$folderName ($count)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: folderColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Row(
              children: _categories.map((category) {
                final count = category == 'Semua'
                    ? _hotels.length
                    : _hotels
                          .where((hotel) => hotel['category'] == category)
                          .length;
                final isActive = _activeCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => _activeCategory = category),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF00B4D8)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$category ($count)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF374151),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }

  Widget _buildHotelCard(Map<String, dynamic> hotel) {
    final imageUrl = hotel['imageUrl']?.toString() ??
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600';
    final typeName = hotel['type']?.toString() ?? 'Resor';
    final locationText = hotel['location']?.toString() ?? '';
    final hotelName = hotel['name']?.toString() ?? 'Penginapan';
    final discount = hotel['discount']?.toString();
    final features = (hotel['features'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>['WiFi Cepat', 'Kolam Renang', 'AC'];
    final extras = (hotel['extras'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];
    final availability = hotel['availability']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: const Color(0xFFE5E7EB),
                    child: const Icon(
                      Icons.hotel,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.terrain, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        typeName,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (discount != null && discount.isNotEmpty)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[700],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '🔥 $discount',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () async {
                    await CustomerDataService.instance.toggleSavedHotel(hotel);
                    await _loadHotels();
                    CustomerDataService.savedHotelsCountNotifier.value = _hotels.length;
                    if (mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${hotel['name'] ?? 'Hotel'} dihapus dari tersimpan',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF9CA3AF),
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        locationText,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  hotelName,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ...features.map(
                      (f) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 12,
                            color: Color(0xFF00B4D8),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            f,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...extras.map(
                      (e) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 12,
                            color: Color(0xFF00B4D8),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            e,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (availability != null && availability.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: availability.contains('Tersedia')
                              ? const Color(0xFFF0FDF4)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          availability,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: availability.contains('Tersedia')
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF3B82F6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        CustomerRouter.hotelDetail,
                        arguments: hotel,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4D8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        'Pesan Sekarang',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
