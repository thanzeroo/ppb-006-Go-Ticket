import '../models/booking_model.dart';
import '../models/hotel_admin_model.dart';
import '../models/hotel_model.dart';
import '../models/maintenance_ticket_model.dart';
import '../models/payout_model.dart';
import '../models/room_model.dart';
import '../models/user_model.dart';

/// Database dummy / mock fallback data ketika Supabase belum terhubung
class MockData {
  MockData._();

  // ---------------------------------------------------------------------------
  // USERS SEED
  // ---------------------------------------------------------------------------
  static final List<UserModel> users = [
    UserModel(
      id: 'usr-customer-01',
      fullName: 'Sulthan Pratama',
      email: 'customer@goticket.id',
      phoneNumber: '081234567890',
      role: UserRole.customer,
      isVerified: true,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    UserModel(
      id: 'STF-2025-084',
      fullName: 'Budi Santoso',
      email: 'staff.fo@grandamora.hotel',
      phoneNumber: '081298765432',
      role: UserRole.staffFo,
      managedHotelId: 'htl-01',
      managedHotelName: 'The Grand Amora Resort & Spa',
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
    UserModel(
      id: 'MTN-2025-012',
      fullName: 'Ahmad Tekno',
      email: 'maintenance@grandamora.hotel',
      phoneNumber: '081333444555',
      role: UserRole.maintenance,
      managedHotelId: 'htl-01',
      managedHotelName: 'The Grand Amora Resort & Spa',
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    UserModel(
      id: 'adm-hotel-01',
      fullName: 'Handoko Wijaya',
      email: 'admin@grandamora.hotel',
      phoneNumber: '081122334455',
      role: UserRole.adminHotel,
      managedHotelId: 'htl-01',
      managedHotelName: 'The Grand Amora Resort & Spa',
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
    UserModel(
      id: 'usr-superadmin-01',
      fullName: 'Go Ticket Super Admin',
      email: 'admin.master@goticket.id',
      phoneNumber: '081999888777',
      role: UserRole.superAdmin,
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
  ];

  // ---------------------------------------------------------------------------
  // HOTELS SEED
  // ---------------------------------------------------------------------------
  static final List<HotelModel> hotels = [
    HotelModel(
      id: 'htl-01',
      name: 'The Grand Amora Resort & Spa',
      shortDescription: 'Seminyak, Bali • 400m dari pantai',
      fullDescription:
          'Resor mewah bintang 5 dengan pemandangan langsung ke pantai Seminyak. Menawarkan infinity pool, spa alami kelas dunia, dan sarapan buffet internasional.',
      address: 'Jl. Petitenget No. 88, Seminyak',
      city: 'Bali',
      province: 'Bali',
      rating: 4.9,
      reviewCount: 349,
      starRating: 5,
      pricePerNight: 850000,
      originalPrice: 1200000,
      thumbnailUrl:
          'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=600',
      photoUrls: [
        'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
      ],
      amenities: [
        'WiFi Cepat',
        'Infinity Pool',
        'Sarapan Gratis',
        'Spa Mewah',
        'Pusat Kebugaran',
        'Restoran Tepi Pantai',
      ],
      status: HotelStatus.active,
      isRecommended: true,
      isPopular: true,
    ),
    HotelModel(
      id: 'htl-02',
      name: 'The Alila Cliff Sanctuary',
      shortDescription: 'Uluwatu, Bali • Panorama Tebing Samudra',
      fullDescription:
          'Terletak di puncak tebing Uluwatu dengan panorama Samudra Hindia 180 derajat. Menghadirkan privasi maksimal dan sunset terbaik di Bali.',
      address: 'Jl. Belimbing Sari, Uluwatu',
      city: 'Bali',
      province: 'Bali',
      rating: 4.8,
      reviewCount: 212,
      starRating: 5,
      pricePerNight: 1450000,
      originalPrice: 1950000,
      thumbnailUrl:
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=600',
      photoUrls: [
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
        'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800',
      ],
      amenities: [
        'Spa Alami',
        'Jacuzzi Privat',
        'Sunset Lounge',
        'WiFi Cepat',
        'Restoran Fine Dining',
      ],
      status: HotelStatus.active,
      isRecommended: true,
      isPopular: true,
    ),
    HotelModel(
      id: 'htl-03',
      name: 'Kayumanis Private Villa',
      shortDescription: 'Kayu Aya, Seminyak • 1 Unit Tersisa',
      fullDescription:
          'Kompleks villa pribadi tropis dengan private pool dan layanan butler 24 jam di pusat Seminyak.',
      address: 'Jl. Kayu Aya, Seminyak',
      city: 'Bali',
      province: 'Bali',
      rating: 4.8,
      reviewCount: 120,
      starRating: 5,
      pricePerNight: 1650000,
      thumbnailUrl:
          'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=600',
      photoUrls: [
        'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800',
      ],
      amenities: [
        'Private Pool',
        'Floating Breakfast',
        'Butler 24 Jam',
        'Bebas Parkir',
      ],
      status: HotelStatus.active,
      isRecommended: false,
      isPopular: true,
    ),
    HotelModel(
      id: 'htl-04',
      name: 'Seminyak Beach Breeze Hotel',
      shortDescription: 'Double Six, Seminyak',
      fullDescription:
          'Akomodasi modern dan nyaman dekat pantai Double Six, sempurna bagi pelancong dan keluarga.',
      address: 'Jl. Double Six No. 12, Seminyak',
      city: 'Bali',
      province: 'Bali',
      rating: 4.7,
      reviewCount: 98,
      starRating: 4,
      pricePerNight: 620000,
      originalPrice: 750000,
      thumbnailUrl:
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600',
      photoUrls: [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
      ],
      amenities: ['Kolam Renang', 'Akses Pantai', 'WiFi Gratis', 'Restoran'],
      status: HotelStatus.active,
      isRecommended: true,
      isPopular: false,
    ),
  ];

  // ---------------------------------------------------------------------------
  // ROOMS SEED
  // ---------------------------------------------------------------------------
  static final List<RoomModel> rooms = [
    RoomModel(
      id: 'rm-01',
      hotelId: 'htl-01',
      roomNumber: '101',
      typeName: 'Deluxe King Pool View',
      description: 'Kamar mewah dengan king bed dan balkon menghadap kolam renang utama.',
      maxGuests: 2,
      pricePerNight: 850000,
      weekendPrice: 950000,
      status: RoomStatus.available,
      photoUrls: [
        'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
      ],
      amenities: ['1 King Bed', 'Balkon Pribadi', 'Smart TV 55"', 'Bathtub', 'Espresso Machine'],
      bedType: '1 King Bed',
      roomSizeM2: 42,
    ),
    RoomModel(
      id: 'rm-02',
      hotelId: 'htl-01',
      roomNumber: '102',
      typeName: 'Grand Ocean Suite',
      description: 'Suite premium dengan ruang tamu terpisah dan pemandangan laut luas.',
      maxGuests: 3,
      pricePerNight: 1250000,
      weekendPrice: 1400000,
      status: RoomStatus.occupied,
      photoUrls: [
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
      ],
      amenities: ['1 Super King Bed', 'Living Area', 'Jacuzzi', 'Akses Club Lounge'],
      bedType: '1 Super King Bed',
      roomSizeM2: 65,
    ),
    RoomModel(
      id: 'rm-03',
      hotelId: 'htl-01',
      roomNumber: '201',
      typeName: 'Executive Suite',
      description: 'Kamar eksekutif modern untuk kenyamanan pebisnis dan liburan.',
      maxGuests: 2,
      pricePerNight: 980000,
      weekendPrice: 1100000,
      status: RoomStatus.cleaning,
      photoUrls: [
        'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
      ],
      amenities: ['1 King Bed', 'Meja Kerja Ergonomis', 'Minibar Gratis'],
      bedType: '1 King Bed',
      roomSizeM2: 50,
    ),
    RoomModel(
      id: 'rm-04',
      hotelId: 'htl-01',
      roomNumber: '205',
      typeName: 'Standard Twin Room',
      description: 'Kamar nyaman dengan twin beds, pas untuk teman perjalanan.',
      maxGuests: 2,
      pricePerNight: 650000,
      weekendPrice: 720000,
      status: RoomStatus.dirty,
      photoUrls: [
        'https://images.unsplash.com/photo-1591088398332-8a7791972843?w=800',
      ],
      amenities: ['2 Twin Beds', 'Shower Air Hangat', 'AC', 'WiFi'],
      bedType: '2 Twin Beds',
      roomSizeM2: 32,
    ),
  ];

  // ---------------------------------------------------------------------------
  // BOOKINGS SEED
  // ---------------------------------------------------------------------------
  static final List<BookingModel> bookings = [
    BookingModel(
      id: 'bkg-2026-001',
      bookingCode: 'GT-AMORA-9281',
      userId: 'usr-customer-01',
      hotelId: 'htl-01',
      hotelName: 'The Grand Amora Resort & Spa',
      hotelAddress: 'Jl. Petitenget No. 88, Seminyak, Bali',
      hotelImageUrl:
          'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=600',
      roomId: 'rm-01',
      roomTypeName: 'Deluxe King Pool View',
      roomNumber: '101',
      guestName: 'Sulthan Pratama',
      guestEmail: 'customer@goticket.id',
      guestPhoneNumber: '081234567890',
      checkInDate: DateTime.now().add(const Duration(days: 2)),
      checkOutDate: DateTime.now().add(const Duration(days: 4)),
      nights: 2,
      totalGuests: 2,
      totalRooms: 1,
      pricePerNight: 850000,
      subtotalPrice: 1700000,
      taxAndServiceFee: 170000,
      discountAmount: 100000,
      totalPrice: 1770000,
      status: BookingStatus.confirmed,
      paymentMethod: 'Bank Mandiri Virtual Account',
      isPaid: true,
      paidAt: DateTime.now().subtract(const Duration(hours: 4)),
      qrCodeData: 'GT-AMORA-9281-CHECKIN-2026',
    ),
    BookingModel(
      id: 'bkg-2026-002',
      bookingCode: 'GT-ALILA-4412',
      userId: 'usr-customer-01',
      hotelId: 'htl-02',
      hotelName: 'The Alila Cliff Sanctuary',
      hotelAddress: 'Jl. Belimbing Sari, Uluwatu, Bali',
      hotelImageUrl:
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=600',
      roomId: 'rm-02',
      roomTypeName: 'Grand Ocean Suite',
      roomNumber: '102',
      guestName: 'Farchan Fauzan',
      guestEmail: 'farchan@example.com',
      guestPhoneNumber: '081399887766',
      checkInDate: DateTime.now().subtract(const Duration(days: 10)),
      checkOutDate: DateTime.now().subtract(const Duration(days: 8)),
      nights: 2,
      totalGuests: 2,
      totalRooms: 1,
      pricePerNight: 1450000,
      subtotalPrice: 2900000,
      taxAndServiceFee: 290000,
      discountAmount: 0,
      totalPrice: 3190000,
      status: BookingStatus.checkedOut,
      paymentMethod: 'BCA Virtual Account',
      isPaid: true,
      paidAt: DateTime.now().subtract(const Duration(days: 10, hours: 2)),
    ),
  ];

  // ---------------------------------------------------------------------------
  // MAINTENANCE TICKETS SEED
  // ---------------------------------------------------------------------------
  static final List<MaintenanceTicketModel> maintenanceTickets = [
    MaintenanceTicketModel(
      id: 'tkt-01',
      hotelId: 'htl-01',
      roomId: 'rm-04',
      roomNumber: '205',
      category: TicketCategory.cleaning,
      title: 'Pembersihan Kamar Tamu Checkout',
      description: 'Tamu sudah checkout pada 12:00. Tolong ganti sprei, handuk, dan disinfeksi.',
      priority: TicketPriority.medium,
      status: TicketStatus.inProgress,
      assignedToName: 'Ahmad Tekno',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    MaintenanceTicketModel(
      id: 'tkt-02',
      hotelId: 'htl-01',
      roomId: 'rm-03',
      roomNumber: '201',
      category: TicketCategory.repair,
      title: 'AC Kamar Menetes & Kurang Dingin',
      description: 'Laporan dari tamu semalam pipa drain AC tersumbat air menetes di dekat meja.',
      priority: TicketPriority.urgent,
      status: TicketStatus.open,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  // ---------------------------------------------------------------------------
  // PROMOS SEED
  // ---------------------------------------------------------------------------
  static final List<Map<String, dynamic>> promos = [
    {
      'id': 'prm-01',
      'code': 'STAYHEMAT',
      'title': 'Diskon Staycation Spesial',
      'description': 'Potongan langsung hingga Rp 150.000 untuk hotel bintang 4 & 5',
      'discountPercent': 15,
      'maxDiscount': 150000,
      'minBookingAmount': 500000,
      'expiredDate': '31 Des 2026',
      'isActive': true,
    },
    {
      'id': 'prm-02',
      'code': 'LIBURANASIK',
      'title': 'Weekend Escape Cashback',
      'description': 'Cashback 20% untuk pemesanan kamar tipe villa dan resort',
      'discountPercent': 20,
      'maxDiscount': 250000,
      'minBookingAmount': 1000000,
      'expiredDate': '30 Nov 2026',
      'isActive': true,
    },
    {
      'id': 'prm-03',
      'code': 'GOHOTEL50',
      'title': 'Pengguna Baru Go Ticket',
      'description': 'Diskon Rp 50.000 tanpa minimum transaksi pertama kali pesan',
      'discountPercent': 10,
      'maxDiscount': 50000,
      'minBookingAmount': 0,
      'expiredDate': '31 Jan 2027',
      'isActive': true,
    },
  ];

  // ---------------------------------------------------------------------------
  // PAYOUTS SEED
  // ---------------------------------------------------------------------------
  static final List<PayoutModel> payouts = [
    PayoutModel(
      id: 'pyt-01',
      hotelId: 'htl-01',
      hotelName: 'The Grand Amora Resort & Spa',
      amount: 48500000,
      bankName: 'BCA',
      accountNumber: '8830192841',
      accountHolderName: 'PT Amora Hospitality Bali',
      status: PayoutStatus.approved,
      requestedAt: DateTime.now().subtract(const Duration(days: 3)),
      processedAt: DateTime.now().subtract(const Duration(days: 2)),
      referenceNumber: 'PO-2026-AMORA-001',
    ),
    PayoutModel(
      id: 'pyt-02',
      hotelId: 'htl-02',
      hotelName: 'The Alila Cliff Sanctuary',
      amount: 72000000,
      bankName: 'Mandiri',
      accountNumber: '1420019284918',
      accountHolderName: 'PT Alila Pratama Indonesia',
      status: PayoutStatus.pending,
      requestedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  // ---------------------------------------------------------------------------
  // HOTEL ADMIN OPERATIONAL SEED
  // ---------------------------------------------------------------------------
  static final List<StaffData> staffList = [
    StaffData(
      id: 'stf-01',
      name: 'Budi Santoso',
      role: 'Front Office Lead',
      shift: 'Pagi (07:00 - 15:00)',
      status: 'Aktif Bertugas',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    ),
    StaffData(
      id: 'stf-02',
      name: 'Ahmad Tekno',
      role: 'Maintenance Technician',
      shift: 'Sore (15:00 - 23:00)',
      status: 'Standby On-Call',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    ),
    StaffData(
      id: 'stf-03',
      name: 'Siti Rahma',
      role: 'Housekeeping Staff',
      shift: 'Pagi (07:00 - 15:00)',
      status: 'Aktif Bertugas',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    ),
  ];
}

