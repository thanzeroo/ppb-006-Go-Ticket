// =============================================================================
// FILE: lib/models/payout_model.dart
// RESPONSIBILITY: Model data untuk Payout / Pencairan Dana Mitra Hotel.
// Mitra hotel dapat mengajukan payout setelah booking di hotel mereka
// selesai (checkedOut). Go Ticket memotong komisi platform sebelum
// mentransfer ke rekening mitra. Mencakup:
// - Informasi pengajuan payout
// - Kalkulasi komisi platform
// - Status disbursement
// - Informasi rekening bank tujuan
// =============================================================================

/// Enum status payout mitra hotel
enum PayoutStatus {
  /// Payout baru diajukan oleh Admin Hotel, menunggu review Super Admin
  pending,

  /// Super Admin sedang memproses transfer
  processing,

  /// Dana sudah berhasil ditransfer ke rekening mitra
  completed,

  /// Payout ditolak oleh Super Admin (dengan alasan)
  rejected,

  /// Payout disetujui
  approved,
}

/// Extension untuk PayoutStatus
extension PayoutStatusExtension on PayoutStatus {
  String get apiValue {
    switch (this) {
      case PayoutStatus.pending:
        return 'pending';
      case PayoutStatus.processing:
        return 'processing';
      case PayoutStatus.completed:
      case PayoutStatus.approved:
        return 'completed';
      case PayoutStatus.rejected:
        return 'rejected';
    }
  }

  static PayoutStatus fromString(String value) {
    switch (value) {
      case 'processing':
        return PayoutStatus.processing;
      case 'completed':
      case 'approved':
      case 'disetujui':
        return PayoutStatus.completed;
      case 'rejected':
      case 'ditolak':
        return PayoutStatus.rejected;
      default:
        return PayoutStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case PayoutStatus.pending:
        return 'Menunggu Proses';
      case PayoutStatus.processing:
        return 'Sedang Diproses';
      case PayoutStatus.completed:
      case PayoutStatus.approved:
        return 'Selesai / Disetujui';
      case PayoutStatus.rejected:
        return 'Ditolak';
    }
  }
}

// =============================================================================
// PAYOUT MODEL
// =============================================================================

/// Model data payout / pencairan dana mitra hotel Go Ticket.
class PayoutModel {
  /// ID unik payout dari database
  final String id;

  /// ID Hotel yang mengajukan payout
  final String hotelId;

  /// Nama Hotel (untuk display)
  final String hotelName;

  /// ID Admin Hotel yang mengajukan
  final String requestedById;

  /// Nama Admin Hotel yang mengajukan
  final String requestedByName;

  /// Periode payout — tanggal mulai
  final DateTime periodStart;

  /// Periode payout — tanggal akhir
  final DateTime periodEnd;

  /// Total pendapatan bruto dari booking yang selesai di periode ini
  final int grossRevenue;

  /// Persentase komisi platform Go Ticket
  final double commissionPercent;

  /// Jumlah komisi platform (dipotong dari grossRevenue)
  final int commissionAmount;

  /// Jumlah bersih yang diterima mitra (grossRevenue - commissionAmount)
  final int netAmount;

  /// Jumlah yang diminta untuk di-payout oleh mitra
  final int requestedAmount;

  /// Status payout
  final PayoutStatus status;

  /// Nama bank tujuan transfer (misalnya: 'BCA', 'Mandiri', 'BRI')
  final String bankName;

  /// Nama pemilik rekening tujuan
  final String bankAccountName;

  /// Nomor rekening tujuan
  final String bankAccountNumber;

  /// Catatan / keterangan dari Admin Hotel saat mengajukan
  final String? notes;

  /// Alasan penolakan oleh Super Admin (jika status = rejected)
  final String? rejectionReason;

  /// ID transaksi transfer dari bank (jika sudah selesai)
  final String? transferTransactionId;

  /// Bukti transfer (URL screenshot/struk)
  final String? transferProofUrl;

  /// ID Super Admin yang memproses payout
  final String? processedById;

  /// Tanggal payout diajukan
  final DateTime createdAt;

  /// Tanggal payout diproses / selesai
  final DateTime? processedAt;

  static final DateTime _defaultDate = DateTime(2026, 1, 1);

  PayoutModel({
    required this.id,
    required this.hotelId,
    required this.hotelName,
    this.requestedById = 'usr-admin-01',
    this.requestedByName = 'Admin Hotel',
    DateTime? periodStart,
    DateTime? periodEnd,
    int? grossRevenue,
    this.commissionPercent = 10,
    int? commissionAmount,
    int? netAmount,
    int? requestedAmount,
    int? amount,
    required this.bankName,
    String? bankAccountName,
    String? accountHolderName,
    String? bankAccountNumber,
    String? accountNumber,
    DateTime? createdAt,
    DateTime? requestedAt,
    this.status = PayoutStatus.pending,
    this.notes,
    this.rejectionReason,
    String? transferTransactionId,
    String? referenceNumber,
    this.transferProofUrl,
    this.processedById,
    this.processedAt,
  })  : requestedAmount = requestedAmount ?? amount ?? 0,
        grossRevenue = grossRevenue ?? requestedAmount ?? amount ?? 0,
        commissionAmount = commissionAmount ?? 0,
        netAmount = netAmount ?? requestedAmount ?? amount ?? 0,
        bankAccountName =
            bankAccountName ?? accountHolderName ?? 'PT Mitra Hotel',
        bankAccountNumber =
            bankAccountNumber ?? accountNumber ?? '0000000000',
        createdAt = createdAt ?? requestedAt ?? _defaultDate,
        transferTransactionId = transferTransactionId ?? referenceNumber,
        periodStart = periodStart ?? _defaultDate,
        periodEnd = periodEnd ?? _defaultDate;

  int get amount => requestedAmount;
  String get accountNumber => bankAccountNumber;
  String get accountHolderName => bankAccountName;
  DateTime get requestedAt => createdAt;
  String? get referenceNumber => transferTransactionId;

  // ---------------------------------------------------------------------------
  // SERIALIZATION
  // ---------------------------------------------------------------------------

  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    PayoutStatus parseStatus(dynamic val) {
      if (val == null) return PayoutStatus.pending;
      final s = val.toString().toLowerCase();
      if (s == 'disetujui' || s == 'approved' || s == 'selesai') {
        return PayoutStatus.completed;
      }
      if (s == 'ditolak' || s == 'rejected') return PayoutStatus.rejected;
      if (s == 'diproses' || s == 'processing') return PayoutStatus.processing;
      return PayoutStatusExtension.fromString(s);
    }

    final now = DateTime.now();
    final pStartStr = json['period_start'] ?? json['tgl_pengajuan'];
    final pEndStr = json['period_end'] ?? json['tgl_jatuh_tempo'];
    final cAtStr = json['created_at'] ?? json['tgl_pengajuan'];

    return PayoutModel(
      id: json['id']?.toString() ?? json['id_monitoring']?.toString() ?? '',
      hotelId: json['hotel_id']?.toString() ??
          json['id_penginapan']?.toString() ??
          '',
      hotelName: json['hotel_name'] ?? 'Mitra Penginapan',
      requestedById: json['requested_by_id']?.toString() ??
          json['disetujui_oleh']?.toString() ??
          '1',
      requestedByName: json['requested_by_name'] ?? 'Owner Penginapan',
      periodStart: pStartStr != null
          ? (DateTime.tryParse(pStartStr) ?? now)
          : now.subtract(const Duration(days: 30)),
      periodEnd: pEndStr != null ? (DateTime.tryParse(pEndStr) ?? now) : now,
      grossRevenue: (json['gross_revenue'] as num?)?.toInt() ??
          (json['nominal_gross'] as num?)?.toInt() ??
          0,
      commissionPercent:
          (json['commission_percent'] as num?)?.toDouble() ?? 10.0,
      commissionAmount: (json['commission_amount'] as num?)?.toInt() ??
          (json['komisi_platform'] as num?)?.toInt() ??
          0,
      netAmount: (json['net_amount'] as num?)?.toInt() ??
          (json['nominal_netto'] as num?)?.toInt() ??
          0,
      requestedAmount: (json['requested_amount'] as num?)?.toInt() ??
          (json['nominal_netto'] as num?)?.toInt() ??
          (json['nominal_gross'] as num?)?.toInt() ??
          0,
      status: parseStatus(json['status_dana'] ?? json['status']),
      bankName: json['bank_name'] ?? json['metode_pencairan'] ?? 'BCA',
      bankAccountName:
          json['bank_account_name'] ?? 'PT Mitra Penginapan Nusantara',
      bankAccountNumber:
          json['bank_account_number'] ?? '8830192841',
      notes: json['notes'] ?? json['keterangan'],
      rejectionReason: json['rejection_reason'],
      transferTransactionId:
          json['transfer_transaction_id'] ?? json['no_referensi_payout'],
      transferProofUrl: json['transfer_proof_url'],
      processedById: json['processed_by_id']?.toString() ??
          json['disetujui_oleh']?.toString(),
      createdAt: cAtStr != null ? (DateTime.tryParse(cAtStr) ?? now) : now,
      processedAt: json['processed_at'] != null
          ? DateTime.tryParse(json['processed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'hotel_name': hotelName,
      'requested_by_id': requestedById,
      'period_start': periodStart.toIso8601String().substring(0, 10),
      'period_end': periodEnd.toIso8601String().substring(0, 10),
      'gross_revenue': grossRevenue,
      'commission_percent': commissionPercent,
      'commission_amount': commissionAmount,
      'net_amount': netAmount,
      'requested_amount': requestedAmount,
      'status': status.apiValue,
      'bank_name': bankName,
      'bank_account_name': bankAccountName,
      'bank_account_number': bankAccountNumber,
      'notes': notes,
    };
  }

  PayoutModel copyWith({
    PayoutStatus? status,
    String? rejectionReason,
    String? transferTransactionId,
    String? referenceNumber,
    String? transferProofUrl,
    String? processedById,
    DateTime? processedAt,
  }) {
    return PayoutModel(
      id: id,
      hotelId: hotelId,
      hotelName: hotelName,
      requestedById: requestedById,
      requestedByName: requestedByName,
      periodStart: periodStart,
      periodEnd: periodEnd,
      grossRevenue: grossRevenue,
      commissionPercent: commissionPercent,
      commissionAmount: commissionAmount,
      netAmount: netAmount,
      requestedAmount: requestedAmount,
      bankName: bankName,
      bankAccountName: bankAccountName,
      bankAccountNumber: bankAccountNumber,
      createdAt: createdAt,
      status: status ?? this.status,
      notes: notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      transferTransactionId:
          referenceNumber ?? transferTransactionId ?? this.transferTransactionId,
      transferProofUrl: transferProofUrl ?? this.transferProofUrl,
      processedById: processedById ?? this.processedById,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  String toString() =>
      'PayoutModel(id: $id, hotel: $hotelName, amount: $requestedAmount, status: ${status.displayName})';
}
