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
        return PayoutStatus.completed;
      case 'rejected':
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
        return 'Dana Diterima';
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

  const PayoutModel({
    required this.id,
    required this.hotelId,
    required this.hotelName,
    required this.requestedById,
    required this.requestedByName,
    required this.periodStart,
    required this.periodEnd,
    required this.grossRevenue,
    required this.commissionPercent,
    required this.commissionAmount,
    required this.netAmount,
    required this.requestedAmount,
    required this.bankName,
    required this.bankAccountName,
    required this.bankAccountNumber,
    required this.createdAt,
    this.status = PayoutStatus.pending,
    this.notes,
    this.rejectionReason,
    this.transferTransactionId,
    this.transferProofUrl,
    this.processedById,
    this.processedAt,
  });

  // ---------------------------------------------------------------------------
  // SERIALIZATION
  // ---------------------------------------------------------------------------

  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    return PayoutModel(
      id: json['id']?.toString() ?? '',
      hotelId: json['hotel_id']?.toString() ?? '',
      hotelName: json['hotel_name'] ?? '',
      requestedById: json['requested_by_id']?.toString() ?? '',
      requestedByName: json['requested_by_name'] ?? '',
      periodStart: DateTime.parse(json['period_start']),
      periodEnd: DateTime.parse(json['period_end']),
      grossRevenue: json['gross_revenue'] ?? 0,
      commissionPercent: (json['commission_percent'] as num?)?.toDouble() ?? 10.0,
      commissionAmount: json['commission_amount'] ?? 0,
      netAmount: json['net_amount'] ?? 0,
      requestedAmount: json['requested_amount'] ?? 0,
      status: PayoutStatusExtension.fromString(json['status'] ?? 'pending'),
      bankName: json['bank_name'] ?? '',
      bankAccountName: json['bank_account_name'] ?? '',
      bankAccountNumber: json['bank_account_number'] ?? '',
      notes: json['notes'],
      rejectionReason: json['rejection_reason'],
      transferTransactionId: json['transfer_transaction_id'],
      transferProofUrl: json['transfer_proof_url'],
      processedById: json['processed_by_id']?.toString(),
      createdAt: DateTime.parse(json['created_at']),
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
          transferTransactionId ?? this.transferTransactionId,
      transferProofUrl: transferProofUrl ?? this.transferProofUrl,
      processedById: processedById ?? this.processedById,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  String toString() =>
      'PayoutModel(id: $id, hotel: $hotelName, amount: $requestedAmount, status: ${status.displayName})';
}
