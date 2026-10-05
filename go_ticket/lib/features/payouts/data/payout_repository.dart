// =============================================================================
// FILE: lib/features/payouts/data/payout_repository.dart
// RESPONSIBILITY: Repository untuk manajemen payout / pencairan dana mitra
// hotel di Go Ticket. Digunakan oleh:
// - Admin Hotel: Melihat laporan keuangan, mengajukan payout
// - Super Admin: Melihat semua payout, approve/reject, proses transfer
// =============================================================================

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../models/payout_model.dart';

/// Repository payout / pencairan dana hotel Go Ticket.
class PayoutRepository {
  final ApiClient _apiClient;

  PayoutRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ---------------------------------------------------------------------------
  // HOTEL ADMIN — Laporan keuangan dan pengajuan payout
  // ---------------------------------------------------------------------------

  /// Mendapatkan laporan keuangan hotel untuk periode tertentu.
  ///
  /// Mengembalikan Map berisi ringkasan pendapatan, booking, dan komisi.
  Future<Map<String, dynamic>> getFinancialReport({
    required String hotelId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.getFinancialReport.replaceAll('{hotelId}', hotelId),
      queryParams: {
        'start_date': startDate.toIso8601String().substring(0, 10),
        'end_date': endDate.toIso8601String().substring(0, 10),
      },
    );
    return response['data'] ?? response;
  }

  /// Mendapatkan riwayat payout hotel.
  ///
  /// [hotelId] — ID hotel
  /// [status] — Filter by status payout
  Future<List<PayoutModel>> getHotelPayouts({
    required String hotelId,
    String? status,
    int page = 1,
  }) async {
    final queryParams = <String, String>{'page': page.toString()};
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      ApiEndpoints.getHotelPayouts.replaceAll('{hotelId}', hotelId),
      queryParams: queryParams,
    );

    final List<dynamic> data = response['data'] ?? response ?? [];
    return data.map((json) => PayoutModel.fromJson(json)).toList();
  }

  /// Admin Hotel mengajukan request payout.
  ///
  /// [hotelId] — ID hotel yang mengajukan
  /// [periodStart] — Awal periode payout
  /// [periodEnd] — Akhir periode payout
  /// [requestedAmount] — Jumlah yang ingin di-withdraw (Rupiah)
  /// [bankName], [bankAccountName], [bankAccountNumber] — Info rekening
  /// [notes] — Catatan opsional
  Future<PayoutModel> requestPayout({
    required String hotelId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int requestedAmount,
    required String bankName,
    required String bankAccountName,
    required String bankAccountNumber,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.requestPayout.replaceAll('{hotelId}', hotelId),
      body: {
        'period_start': periodStart.toIso8601String().substring(0, 10),
        'period_end': periodEnd.toIso8601String().substring(0, 10),
        'requested_amount': requestedAmount,
        'bank_name': bankName,
        'bank_account_name': bankAccountName,
        'bank_account_number': bankAccountNumber,
        'notes': notes,
      },
    );

    return PayoutModel.fromJson(response['data'] ?? response);
  }

  // ---------------------------------------------------------------------------
  // SUPER ADMIN — Melihat dan memproses semua payout
  // ---------------------------------------------------------------------------

  /// Mendapatkan semua payout di seluruh platform (Super Admin only).
  Future<List<PayoutModel>> getAllPayouts({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      ApiEndpoints.getAllPayouts,
      queryParams: queryParams,
    );

    final List<dynamic> data = response['data'] ?? response ?? [];
    return data.map((json) => PayoutModel.fromJson(json)).toList();
  }

  /// Super Admin menyetujui dan memproses payout (melakukan transfer).
  ///
  /// [payoutId] — ID payout yang disetujui
  /// [transferTransactionId] — ID transaksi transfer dari bank
  /// [transferProofUrl] — URL screenshot/bukti transfer
  Future<PayoutModel> processPayout({
    required String payoutId,
    required String transferTransactionId,
    String? transferProofUrl,
  }) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.processPayout.replaceAll('{payoutId}', payoutId)}/approve',
      body: {
        'transfer_transaction_id': transferTransactionId,
        'transfer_proof_url': transferProofUrl,
      },
    );
    return PayoutModel.fromJson(response['data'] ?? response);
  }

  /// Super Admin menolak payout dengan alasan.
  Future<PayoutModel> rejectPayout({
    required String payoutId,
    required String rejectionReason,
  }) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.processPayout.replaceAll('{payoutId}', payoutId)}/reject',
      body: {'rejection_reason': rejectionReason},
    );
    return PayoutModel.fromJson(response['data'] ?? response);
  }
}
