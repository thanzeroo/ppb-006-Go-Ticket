import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

/// Service untuk data dinamis spesifik tiap Customer (Saved Hotels, Tamu Tersimpan, Poin).
/// Memastikan bahwa saat pengguna BARU mendaftar, semua data berstatus FRESH (0 riwayat, 0 pesanan, 0 favorit).
class CustomerDataService {
  CustomerDataService._();
  static final CustomerDataService instance = CustomerDataService._();

  static const String demoUserId = 'usr-customer-01';

  /// Cek apakah pengguna saat ini adalah pengguna baru / fresh account
  bool get isFreshUser {
    final user = AuthService.instance.currentUser;
    if (user == null) return false;
    // Jika bukan demo user dan ID menunjukkan user baru
    return user.id != demoUserId && !user.id.contains('demo');
  }

  // ---------------------------------------------------------------------------
  // POIN & MEMBERSHIP TIER
  // ---------------------------------------------------------------------------
  int getRewardPoints() {
    final user = AuthService.instance.currentUser;
    if (user == null || isFreshUser) {
      return 0; // Pengguna baru mulai dari 0 poin
    }
    return 1250; // Demo user
  }

  String getMembershipTier() {
    final user = AuthService.instance.currentUser;
    if (user == null || isFreshUser) {
      return 'MEMBER BRONZE GO TICKET';
    }
    return 'MEMBER PLATINUM GO TICKET';
  }

  // ---------------------------------------------------------------------------
  // SAVED HOTELS PER USER
  // ---------------------------------------------------------------------------
  static final ValueNotifier<int> savedHotelsCountNotifier = ValueNotifier<int>(0);

  Future<List<Map<String, dynamic>>> getSavedHotels() async {
    final user = AuthService.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();

    if (user == null) return [];

    final key = 'saved_hotels_${user.id}';
    final raw = prefs.getString(key);

    if (raw != null) {
      try {
        final List<dynamic> decoded = jsonDecode(raw);
        final list = decoded.cast<Map<String, dynamic>>();
        savedHotelsCountNotifier.value = list.length;
        return list;
      } catch (_) {}
    }

    // Jika pengguna baru mendaftar, kembalikan list KOSONG (fresh!)
    if (isFreshUser) {
      savedHotelsCountNotifier.value = 0;
      return [];
    }

    // Untuk demo user, berikan data default sesuai screenshot
    final demoHotels = _defaultDemoHotels;
    savedHotelsCountNotifier.value = demoHotels.length;
    return List<Map<String, dynamic>>.from(demoHotels);
  }

  Future<bool> toggleSavedHotel(Map<String, dynamic> hotel) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final key = 'saved_hotels_${user.id}';
    final currentList = await getSavedHotels();

    final hotelId = hotel['id']?.toString() ?? hotel['name']?.toString() ?? '';
    final existingIndex = currentList.indexWhere(
      (h) => (h['id']?.toString() ?? h['name']?.toString()) == hotelId,
    );

    bool isSavedNow;
    if (existingIndex >= 0) {
      currentList.removeAt(existingIndex);
      isSavedNow = false;
    } else {
      currentList.add(Map<String, dynamic>.from(hotel));
      isSavedNow = true;
    }

    await prefs.setString(key, jsonEncode(currentList));
    savedHotelsCountNotifier.value = currentList.length;
    return isSavedNow;
  }

  Future<bool> isHotelSaved(String hotelIdOrName) async {
    final list = await getSavedHotels();
    return list.any((h) =>
        h['id']?.toString() == hotelIdOrName ||
        h['name']?.toString().toLowerCase() == hotelIdOrName.toLowerCase());
  }

  // ---------------------------------------------------------------------------
  // DATA TAMU TERSIMPAN (SAVED GUESTS) PER USER
  // ---------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getSavedGuests() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return [];

    final prefs = await SharedPreferences.getInstance();
    final key = 'saved_guests_${user.id}';
    final raw = prefs.getString(key);

    if (raw != null) {
      try {
        final List<dynamic> decoded = jsonDecode(raw);
        return decoded.cast<Map<String, dynamic>>();
      } catch (_) {}
    }

    // Pengguna baru -> fresh (0 tamu)
    if (isFreshUser) {
      return [];
    }

    // Demo user
    return [
      {
        'name': user.fullName.isNotEmpty ? user.fullName : 'Aditya Pratama',
        'title': 'Tn.',
        'phone': user.phoneNumber ?? '0812-3456-7890',
        'email': user.email ?? 'aditya.pratama@email.com',
        'isPrimary': true,
      },
      {
        'name': 'Rina Maharani',
        'title': 'Ny.',
        'phone': '0813-9988-7766',
        'email': 'rina.m@email.com',
        'isPrimary': false,
      },
      {
        'name': 'Kevin Sanjaya',
        'title': 'Tn.',
        'phone': '0857-1122-3344',
        'email': 'kevin.s@email.com',
        'isPrimary': false,
      },
    ];
  }

  // ---------------------------------------------------------------------------
  // DEFAULT DEMO SAVED HOTELS (Sesuai Screenshot Gambar 2)
  // ---------------------------------------------------------------------------
  static final List<Map<String, dynamic>> _defaultDemoHotels = [
    {
      'id': 'htl-01',
      'name': 'The Grand Amora Resort & Spa',
      'location': 'Seminyak, Bali • 450m dari Pantai Petitenget',
      'type': 'Resor Mewah',
      'rating': '5.0',
      'originalPrice': 'Rp 1.100.000',
      'price': 'Rp 850.000',
      'discount': 'Hemat 25%',
      'features': ['Infinity Pool', 'Spa & Wellness'],
      'extras': ['Sarapan Gratis'],
      'availability': 'Tersedia 2 Kamar',
      'priceValue': 850000,
      'category': 'Resor Bali',
      'folders': ['Liburan Akhir Tahun', 'Staycation Romantis'],
      'imageUrl':
          'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=400',
      'isFavorite': true,
    },
    {
      'id': 'htl-02',
      'name': 'Kayumanis Private Villa',
      'location': 'Ubud, Bali • Nuansa Hutan Tropis',
      'type': 'Villa Mewah',
      'rating': '4.9',
      'originalPrice': null,
      'price': 'Rp 1.450.000',
      'discount': null,
      'features': ['Private Pool', 'Jacuzzi Pribadi'],
      'extras': ['Romantic Dinner'],
      'availability': 'Best Seller',
      'priceValue': 1450000,
      'category': 'Villa Privat',
      'folders': ['Staycation Romantis'],
      'imageUrl':
          'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=400',
      'isFavorite': true,
    },
    {
      'id': 'htl-03',
      'name': 'Seminyak Beach Breeze Hotel',
      'location': 'Seminyak, Bali • Kawasan Pantai Utama',
      'type': 'Bintang 4',
      'rating': '4.7',
      'originalPrice': null,
      'price': 'Rp 550.000',
      'discount': null,
      'features': ['Wi-Fi Cepat', 'Gym Center', 'Coffee Bar'],
      'extras': ['Akses Langsung Pantai'],
      'availability': 'Populer',
      'priceValue': 550000,
      'category': 'Resor Bali',
      'folders': ['Liburan Akhir Tahun'],
      'imageUrl':
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400',
      'isFavorite': true,
    },
  ];
}

