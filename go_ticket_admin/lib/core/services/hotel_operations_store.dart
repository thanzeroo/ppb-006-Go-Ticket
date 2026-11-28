import 'package:flutter/foundation.dart';
import '../models/maintenance_ticket_model.dart';

/// Tipe proses check-out tamu
enum CheckoutType {
  /// Check-out normal saat durasi menginap selesai tanpa perpanjangan
  normal,

  /// Tamu check-out lebih awal dari tanggal selesai reservasi
  early,

  /// Tamu dikeluarkan paksa oleh pihak hotel karena pelanggaran aturan
  forcedExpulsion,
}

/// Model riwayat check-out tamu
class CheckoutRecord {
  final String id;
  final String bookingId;
  final String bookingCode;
  final String guestName;
  final String? guestPhone;
  final String roomNumber;
  final int floorNumber;
  final String roomTypeName;
  final DateTime checkInDate;
  final DateTime scheduledCheckOutDate;
  final DateTime actualCheckOutDate;
  final CheckoutType type;
  final String? noteOrReason;
  final int? additionalFee;
  final int? penaltyAmount;
  final String processedBy;

  const CheckoutRecord({
    required this.id,
    required this.bookingId,
    required this.bookingCode,
    required this.guestName,
    this.guestPhone,
    required this.roomNumber,
    required this.floorNumber,
    required this.roomTypeName,
    required this.checkInDate,
    required this.scheduledCheckOutDate,
    required this.actualCheckOutDate,
    required this.type,
    this.noteOrReason,
    this.additionalFee,
    this.penaltyAmount,
    required this.processedBy,
  });

  String get typeLabel {
    switch (type) {
      case CheckoutType.normal:
        return 'Normal Selesai';
      case CheckoutType.early:
        return 'Check-out Lebih Awal';
      case CheckoutType.forcedExpulsion:
        return 'Dikeluarkan Paksa (Pelanggaran)';
    }
  }
}

/// Item kamar yang perlu dibersihkan oleh tim maintenance / housekeeping
class CleaningTaskItem {
  final String id;
  final String roomNumber;
  final int floorNumber;
  final String roomTypeName;
  final String? previousGuestName;
  final DateTime checkoutTime;
  final CheckoutType checkoutType;
  final String? checkoutReason;
  bool isCleaning; // Sedang dibersihkan
  bool isCleaned; // Selesai dibersihkan & siap huni
  DateTime? cleanedAt; // Time log saat selesai
  String? cleanedBy;
  List<String> checklistNotes;

  CleaningTaskItem({
    required this.id,
    required this.roomNumber,
    required this.floorNumber,
    required this.roomTypeName,
    this.previousGuestName,
    required this.checkoutTime,
    required this.checkoutType,
    this.checkoutReason,
    this.isCleaning = false,
    this.isCleaned = false,
    this.cleanedAt,
    this.cleanedBy,
    this.checklistNotes = const [],
  });
}

/// Model pengajuan akun administrator ke Go Ticket via email
class AdminAccountRequest {
  final String id;
  final String candidateName;
  final String candidateEmail;
  final String candidatePhone;
  final String hotelName;
  final String reason;
  final String targetEmail;
  final DateTime requestedAt;

  const AdminAccountRequest({
    required this.id,
    required this.candidateName,
    required this.candidateEmail,
    required this.candidatePhone,
    required this.hotelName,
    required this.reason,
    required this.targetEmail,
    required this.requestedAt,
  });
}

/// Singleton Store Operasional Hotel untuk menyelaraskan alur:
/// Front Office (Booking, Check-in, Perpanjangan, Check-out, Keluar Paksa)
/// & Maintenance (Daftar Kebersihan Kamar per Lantai, Checklist Sanitasi, Tiket Kerusakan)
/// Serta Administrator (Permohonan Akun Administrator via Email ke Go Ticket)
class HotelOperationsStore extends ChangeNotifier {
  HotelOperationsStore._();
  static final HotelOperationsStore instance = HotelOperationsStore._();

  // Daftar riwayat check-out
  final List<CheckoutRecord> _checkoutHistory = [];

  // Antrean kamar yang perlu dibersihkan oleh Maintenance
  final List<CleaningTaskItem> _cleaningQueue = [];

  // Riwayat pembersihan yang sudah selesai
  final List<CleaningTaskItem> _cleanedHistory = [];

  // Daftar pengajuan akun administrator via email ke Go Ticket
  final List<AdminAccountRequest> _adminRequests = [];

  // Daftar tiket laporan kerusakan fasilitas
  final List<MaintenanceTicketModel> _damageTickets = [];

  // Perpanjangan durasi menginap lokal per booking ID (bookingId -> extraNights)
  final Map<String, int> _extendedNights = {};
  final Map<String, int> _extensionAdditionalCosts = {};

  // E-tiket yang sudah diverifikasi / di-scan (bookingId -> timestamp)
  final Map<String, DateTime> _verifiedETickets = {};

  List<CheckoutRecord> get checkoutHistory => List.unmodifiable(_checkoutHistory);
  List<CleaningTaskItem> get cleaningQueue => List.unmodifiable(_cleaningQueue);
  List<CleaningTaskItem> get cleanedHistory => List.unmodifiable(_cleanedHistory);
  List<AdminAccountRequest> get adminRequests => List.unmodifiable(_adminRequests);
  List<MaintenanceTicketModel> get damageTickets => List.unmodifiable(_damageTickets);

  int getExtendedNights(String bookingId) => _extendedNights[bookingId] ?? 0;
  int getAdditionalCost(String bookingId) => _extensionAdditionalCosts[bookingId] ?? 0;
  bool isETicketVerified(String bookingId) => _verifiedETickets.containsKey(bookingId);
  DateTime? getVerificationTime(String bookingId) => _verifiedETickets[bookingId];

  /// Tambah tiket kerusakan baru (Time log otomatis tercatat saat submit)
  void addDamageTicket(MaintenanceTicketModel ticket) {
    _damageTickets.insert(0, ticket);
    notifyListeners();
  }

  /// Perbarui status tiket kerusakan (Open -> In Progress -> Resolved)
  void updateDamageTicketStatus(String ticketId, MaintenanceStatus newStatus, {String? resolutionNotes}) {
    final idx = _damageTickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      final old = _damageTickets[idx];
      _damageTickets[idx] = old.copyWith(
        status: newStatus,
        resolutionNotes: resolutionNotes ?? old.resolutionNotes,
        resolvedAt: newStatus == MaintenanceStatus.resolved ? DateTime.now() : old.resolvedAt,
      );
      notifyListeners();
    }
  }

  /// Verifikasi E-Tiket Tamu (setelah scan barcode / kamera)
  void verifyETicket(String bookingId) {
    _verifiedETickets[bookingId] = DateTime.now();
    notifyListeners();
  }

  /// Perpanjang durasi menginap tamu
  void extendStay({
    required String bookingId,
    required int additionalNights,
    required int additionalCost,
  }) {
    _extendedNights[bookingId] = (_extendedNights[bookingId] ?? 0) + additionalNights;
    _extensionAdditionalCosts[bookingId] =
        (_extensionAdditionalCosts[bookingId] ?? 0) + additionalCost;
    notifyListeners();
  }

  /// Memproses Check-out Tamu (Normal, Early, atau Keluar Paksa)
  /// Otomatis mencatat riwayat di Halaman Check-out dan meneruskan kamar ke Halaman Kebersihan Maintenance!
  void processCheckout({
    required String bookingId,
    required String bookingCode,
    required String guestName,
    String? guestPhone,
    required String roomNumber,
    required int floorNumber,
    required String roomTypeName,
    required DateTime checkInDate,
    required DateTime scheduledCheckOutDate,
    required CheckoutType type,
    String? noteOrReason,
    int? penaltyAmount,
    required String processedBy,
  }) {
    final now = DateTime.now();

    // 1. Simpan ke Riwayat Check-out
    final record = CheckoutRecord(
      id: 'CO-${now.millisecondsSinceEpoch}',
      bookingId: bookingId,
      bookingCode: bookingCode,
      guestName: guestName,
      guestPhone: guestPhone,
      roomNumber: roomNumber,
      floorNumber: floorNumber,
      roomTypeName: roomTypeName,
      checkInDate: checkInDate,
      scheduledCheckOutDate: scheduledCheckOutDate,
      actualCheckOutDate: now,
      type: type,
      noteOrReason: noteOrReason,
      penaltyAmount: penaltyAmount,
      processedBy: processedBy,
    );
    _checkoutHistory.insert(0, record);

    // 2. Teruskan kamar ke antrean Kebersihan Maintenance
    final cleanItem = CleaningTaskItem(
      id: 'CLN-${now.millisecondsSinceEpoch}',
      roomNumber: roomNumber,
      floorNumber: floorNumber,
      roomTypeName: roomTypeName,
      previousGuestName: guestName,
      checkoutTime: now,
      checkoutType: type,
      checkoutReason: noteOrReason,
    );
    // Hapus duplikat antrean untuk kamar yang sama jika ada
    _cleaningQueue.removeWhere((item) => item.roomNumber == roomNumber);
    _cleaningQueue.insert(0, cleanItem);

    notifyListeners();
  }

  /// Mulai proses pembersihan kamar oleh maintenance
  void startCleaning(String taskId) {
    final idx = _cleaningQueue.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _cleaningQueue[idx].isCleaning = true;
      notifyListeners();
    }
  }

  /// Selesai membersihkan kamar dengan checklist sanitasi (Time log otomatis tercatat saat submit)
  void finishCleaning({
    required String taskId,
    required String cleanedBy,
    required List<String> checklistNotes,
  }) {
    final idx = _cleaningQueue.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final item = _cleaningQueue.removeAt(idx);
      item.isCleaning = false;
      item.isCleaned = true;
      item.cleanedAt = DateTime.now(); // Time log otomatis submit
      item.cleanedBy = cleanedBy;
      item.checklistNotes = checklistNotes;
      _cleanedHistory.insert(0, item);
      notifyListeners();
    }
  }

  /// Kirim pengajuan akun administrator via email ke Go Ticket
  void submitAdminAccountRequest({
    required String candidateName,
    required String candidateEmail,
    required String candidatePhone,
    required String hotelName,
    required String reason,
    String targetEmail = 'admin@goticket.id',
  }) {
    final req = AdminAccountRequest(
      id: 'REQ-${DateTime.now().millisecondsSinceEpoch}',
      candidateName: candidateName,
      candidateEmail: candidateEmail,
      candidatePhone: candidatePhone,
      hotelName: hotelName,
      reason: reason,
      targetEmail: targetEmail,
      requestedAt: DateTime.now(),
    );
    _adminRequests.insert(0, req);
    notifyListeners();
  }
}
