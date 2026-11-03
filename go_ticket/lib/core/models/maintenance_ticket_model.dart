// =============================================================================
// FILE: lib/models/maintenance_ticket_model.dart
// RESPONSIBILITY: Model data untuk Tiket Maintenance / Laporan Kerusakan
// yang dibuat oleh Staff Maintenance di Hotel Partner App. Mencakup:
// - Informasi kerusakan / masalah yang dilaporkan
// - Kamar yang bermasalah
// - Status penanganan tiket
// - Prioritas perbaikan
// - Foto kerusakan dan foto setelah diperbaiki
// =============================================================================

/// Enum status tiket maintenance
enum MaintenanceStatus {
  /// Tiket baru dibuat, menunggu ditangani
  open,

  /// Tiket sedang dalam proses perbaikan
  inProgress,

  /// Perbaikan selesai, menunggu verifikasi
  resolved,

  /// Tiket ditutup (sudah selesai dan diverifikasi)
  closed,
}

/// Extension untuk MaintenanceStatus
extension MaintenanceStatusExtension on MaintenanceStatus {
  String get apiValue {
    switch (this) {
      case MaintenanceStatus.open:
        return 'open';
      case MaintenanceStatus.inProgress:
        return 'in_progress';
      case MaintenanceStatus.resolved:
        return 'resolved';
      case MaintenanceStatus.closed:
        return 'closed';
    }
  }

  static MaintenanceStatus fromString(String value) {
    switch (value) {
      case 'in_progress':
        return MaintenanceStatus.inProgress;
      case 'resolved':
        return MaintenanceStatus.resolved;
      case 'closed':
        return MaintenanceStatus.closed;
      default:
        return MaintenanceStatus.open;
    }
  }

  String get displayName {
    switch (this) {
      case MaintenanceStatus.open:
        return 'Terbuka';
      case MaintenanceStatus.inProgress:
        return 'Dalam Proses';
      case MaintenanceStatus.resolved:
        return 'Selesai Diperbaiki';
      case MaintenanceStatus.closed:
        return 'Ditutup';
    }
  }
}

/// Enum prioritas tiket maintenance
enum MaintenancePriority {
  /// Tidak mendesak, bisa dijadwalkan
  low,

  /// Perlu ditangani segera dalam 24-48 jam
  medium,

  /// Sangat mendesak, mempengaruhi operasional hotel
  high,

  /// Darurat — harus ditangani segera (misal: kebocoran listrik, pipa bocor)
  critical,
}

/// Extension untuk MaintenancePriority
extension MaintenancePriorityExtension on MaintenancePriority {
  String get apiValue {
    switch (this) {
      case MaintenancePriority.low:
        return 'low';
      case MaintenancePriority.medium:
        return 'medium';
      case MaintenancePriority.high:
        return 'high';
      case MaintenancePriority.critical:
        return 'critical';
    }
  }

  static MaintenancePriority fromString(String value) {
    switch (value) {
      case 'medium':
        return MaintenancePriority.medium;
      case 'high':
        return MaintenancePriority.high;
      case 'critical':
        return MaintenancePriority.critical;
      default:
        return MaintenancePriority.low;
    }
  }

  String get displayName {
    switch (this) {
      case MaintenancePriority.low:
        return 'Rendah';
      case MaintenancePriority.medium:
        return 'Sedang';
      case MaintenancePriority.high:
        return 'Tinggi';
      case MaintenancePriority.critical:
        return 'Kritis';
    }
  }
}

// =============================================================================
// MAINTENANCE TICKET MODEL
// =============================================================================

/// Model data tiket maintenance untuk Hotel Partner App.
class MaintenanceTicketModel {
  /// ID unik tiket dari database
  final String id;

  /// ID Hotel tempat kerusakan terjadi
  final String hotelId;

  /// ID Kamar yang bermasalah
  final String? roomId;

  /// Nomor kamar (untuk display)
  final String? roomNumber;

  /// ID Staff yang melaporkan kerusakan
  final String reportedById;

  /// Nama Staff yang melaporkan
  final String reportedByName;

  /// Judul singkat laporan kerusakan
  final String title;

  /// Deskripsi detail kerusakan atau masalah
  final String description;

  /// Kategori kerusakan (misalnya: 'Listrik', 'Air/Ledeng', 'Furnitur', 'AC/Elektronik')
  final String category;

  /// Prioritas penanganan
  final MaintenancePriority priority;

  /// Status tiket saat ini
  final MaintenanceStatus status;

  /// Daftar foto kerusakan yang dilampirkan
  final List<String> damagePhotoUrls;

  /// Foto setelah perbaikan selesai
  final List<String> resolvedPhotoUrls;

  /// ID Staff yang mengerjakan perbaikan (jika sudah ditugaskan)
  final String? assignedToId;

  /// Nama Staff yang mengerjakan
  final String? assignedToName;

  /// Catatan dari staff yang mengerjakan perbaikan
  final String? resolutionNotes;

  /// Estimasi biaya perbaikan (Rupiah)
  final int? estimatedCost;

  /// Biaya aktual perbaikan
  final int? actualCost;

  /// Tanggal tiket dibuat
  final DateTime createdAt;

  /// Tanggal tiket mulai dikerjakan
  final DateTime? startedAt;

  /// Tanggal perbaikan selesai
  final DateTime? resolvedAt;

  /// Tanggal tiket ditutup
  final DateTime? closedAt;

  const MaintenanceTicketModel({
    required this.id,
    required this.hotelId,
    required this.reportedById,
    required this.reportedByName,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    this.roomId,
    this.roomNumber,
    this.priority = MaintenancePriority.medium,
    this.status = MaintenanceStatus.open,
    this.damagePhotoUrls = const [],
    this.resolvedPhotoUrls = const [],
    this.assignedToId,
    this.assignedToName,
    this.resolutionNotes,
    this.estimatedCost,
    this.actualCost,
    this.startedAt,
    this.resolvedAt,
    this.closedAt,
  });

  // ---------------------------------------------------------------------------
  // SERIALIZATION
  // ---------------------------------------------------------------------------

  factory MaintenanceTicketModel.fromJson(Map<String, dynamic> json) {
    MaintenancePriority parsePriority(dynamic val) {
      if (val == null) return MaintenancePriority.medium;
      final s = val.toString().toLowerCase();
      if (s == 'urgent' || s == 'tinggi') return MaintenancePriority.urgent;
      if (s == 'rendah' || s == 'low') return MaintenancePriority.low;
      return MaintenancePriorityExtension.fromString(s);
    }

    MaintenanceStatus parseStatus(dynamic val) {
      if (val == null) return MaintenanceStatus.open;
      final s = val.toString().toLowerCase();
      if (s == 'selesai' || s == 'bersih' || s == 'resolved') {
        return MaintenanceStatus.resolved;
      }
      if (s == 'dalam_proses' || s == 'in_progress' || s == 'sedang_dibersihkan') {
        return MaintenanceStatus.inProgress;
      }
      return MaintenanceStatusExtension.fromString(s);
    }

    final cAtStr = json['created_at'] ?? json['tgl_lapor'] ?? json['tgl_tugas'];

    return MaintenanceTicketModel(
      id: json['id']?.toString() ??
          json['id_tiket_kerusakan']?.toString() ??
          json['id_tugas_kebersihan']?.toString() ??
          '',
      hotelId: json['hotel_id']?.toString() ?? '1',
      roomId: json['room_id']?.toString() ?? json['id_kamar']?.toString(),
      roomNumber: json['room_number'] ??
          (json['id_kamar'] != null ? 'Kamar ${json['id_kamar']}' : null),
      reportedById: json['reported_by_id']?.toString() ??
          json['dilaporkan_oleh']?.toString() ??
          '1',
      reportedByName: json['reported_by_name'] ?? 'Staff Ops',
      title: json['title'] ??
          json['judul_masalah'] ??
          (json['id_tugas_kebersihan'] != null
              ? 'Tugas Kebersihan Kamar'
              : 'Perbaikan Fasilitas'),
      description: json['description'] ??
          json['deskripsi_kerusakan'] ??
          json['catatan_kebersihan'] ??
          '',
      category: json['category'] ??
          (json['id_tugas_kebersihan'] != null ? 'Kebersihan' : 'Kerusakan'),
      priority: parsePriority(json['tingkat_prioritas'] ?? json['priority']),
      status: parseStatus(json['status_perbaikan'] ??
          json['status_kebersihan'] ??
          json['status']),
      damagePhotoUrls: (json['damage_photo_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      resolvedPhotoUrls: (json['resolved_photo_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      assignedToId: json['assigned_to_id']?.toString() ??
          json['ditugaskan_ke']?.toString() ??
          json['id_staf_petugas']?.toString(),
      assignedToName: json['assigned_to_name'] ?? 'Teknisi Maintenance',
      resolutionNotes: json['resolution_notes'] ?? json['tindakan_perbaikan'],
      estimatedCost: json['estimated_cost'],
      actualCost: json['actual_cost'],
      createdAt: cAtStr != null
          ? (DateTime.tryParse(cAtStr) ?? DateTime.now())
          : DateTime.now(),
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'])
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.tryParse(json['resolved_at'])
          : (json['tgl_selesai'] != null
              ? DateTime.tryParse(json['tgl_selesai'])
              : null),
      closedAt: json['closed_at'] != null
          ? DateTime.tryParse(json['closed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'room_id': roomId,
      'room_number': roomNumber,
      'reported_by_id': reportedById,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority.apiValue,
      'status': status.apiValue,
      'damage_photo_urls': damagePhotoUrls,
    };
  }

  MaintenanceTicketModel copyWith({
    MaintenanceStatus? status,
    String? assignedToId,
    String? assignedToName,
    String? resolutionNotes,
    DateTime? startedAt,
    DateTime? resolvedAt,
  }) {
    return MaintenanceTicketModel(
      id: id,
      hotelId: hotelId,
      reportedById: reportedById,
      reportedByName: reportedByName,
      title: title,
      description: description,
      category: category,
      createdAt: createdAt,
      roomId: roomId,
      roomNumber: roomNumber,
      priority: priority,
      status: status ?? this.status,
      damagePhotoUrls: damagePhotoUrls,
      resolvedPhotoUrls: resolvedPhotoUrls,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToName: assignedToName ?? this.assignedToName,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      estimatedCost: estimatedCost,
      actualCost: actualCost,
      startedAt: startedAt ?? this.startedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  String toString() =>
      'MaintenanceTicketModel(id: $id, title: $title, status: ${status.displayName})';
}
