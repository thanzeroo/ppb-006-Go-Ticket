// =============================================================================
// FILE: lib/models/user_model.dart
// RESPONSIBILITY: Mendefinisikan model data untuk User (pengguna) di platform
// Go Ticket. Mencakup semua tipe user dengan sistem Role:
// - customer: Tamu yang memesan hotel
// - staff_fo: Staff Front Office hotel
// - maintenance: Staff Maintenance hotel
// - admin_hotel: Manager / Owner hotel mitra
// - super_admin: Platform owner Go Ticket
// =============================================================================

/// Enum yang merepresentasikan semua role user di platform Go Ticket.
enum UserRole {
  /// Tamu yang menggunakan aplikasi untuk memesan hotel
  customer,

  /// Staff Front Office — menangani check-in, check-out, verifikasi pembayaran
  staffFo,

  /// Staff Maintenance — menangani kebersihan dan perbaikan kamar
  maintenance,

  /// Admin / Manager Hotel — mengelola operasional dan keuangan hotel
  adminHotel,

  /// Super Admin — platform owner, mengelola seluruh ekosistem Go Ticket
  superAdmin,
}

/// Extension untuk UserRole — helper method untuk konversi & display
extension UserRoleExtension on UserRole {
  /// Konversi role ke string untuk dikirim ke API
  String get apiValue {
    switch (this) {
      case UserRole.customer:
        return 'customer';
      case UserRole.staffFo:
        return 'staff_fo';
      case UserRole.maintenance:
        return 'maintenance';
      case UserRole.adminHotel:
        return 'admin_hotel';
      case UserRole.superAdmin:
        return 'super_admin';
    }
  }

  /// Parse string dari API menjadi UserRole enum
  static UserRole fromApiString(String value) {
    switch (value) {
      case 'customer':
        return UserRole.customer;
      case 'staff_fo':
        return UserRole.staffFo;
      case 'maintenance':
        return UserRole.maintenance;
      case 'admin_hotel':
        return UserRole.adminHotel;
      case 'super_admin':
        return UserRole.superAdmin;
      default:
        return UserRole.customer;
    }
  }

  /// Label yang bisa ditampilkan ke user (Bahasa Indonesia)
  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Tamu';
      case UserRole.staffFo:
        return 'Staff Front Office';
      case UserRole.maintenance:
        return 'Staff Maintenance';
      case UserRole.adminHotel:
        return 'Admin Hotel';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }
}

// =============================================================================
// USER MODEL
// =============================================================================

/// Model data untuk pengguna platform Go Ticket.
///
/// Digunakan oleh semua aplikasi (Customer, Hotel Partner, Super Admin)
/// dengan field yang disesuaikan berdasarkan role-nya.
class UserModel {
  /// ID unik user dari database
  final String id;

  /// Nama lengkap user
  final String fullName;

  /// Alamat email user
  final String? email;

  /// Nomor HP (wajib untuk customer, opsional untuk staff)
  final String? phoneNumber;

  /// URL foto profil user
  final String? avatarUrl;

  /// Role user di platform Go Ticket
  final UserRole role;

  /// ID hotel yang dikelola (hanya untuk staffFo, maintenance, adminHotel)
  final String? managedHotelId;

  /// Nama hotel yang dikelola (untuk display di UI)
  final String? managedHotelName;

  /// Apakah akun user aktif / tidak diblokir
  final bool isActive;

  /// Apakah nomor HP/email sudah diverifikasi
  final bool isVerified;

  /// Tanggal daftar akun
  final DateTime? createdAt;

  /// Tanggal update terakhir
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.role,
    this.managedHotelId,
    this.managedHotelName,
    this.isActive = true,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  // ---------------------------------------------------------------------------
  // CONVENIENCE GETTERS
  // ---------------------------------------------------------------------------

  /// Mendapatkan inisial nama untuk avatar placeholder
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  /// Mengecek apakah user adalah staff hotel (bukan customer/super admin)
  bool get isHotelStaff =>
      role == UserRole.staffFo ||
      role == UserRole.maintenance ||
      role == UserRole.adminHotel;

  // ---------------------------------------------------------------------------
  // SERIALIZATION — JSON ke Model dan sebaliknya
  // ---------------------------------------------------------------------------

  /// Factory constructor dari JSON response API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? json['name'] ?? '',
      email: json['email'],
      phoneNumber: json['phone_number'] ?? json['phone'],
      avatarUrl: json['avatar_url'] ?? json['photo'],
      role: UserRoleExtension.fromApiString(json['role'] ?? 'customer'),
      managedHotelId: json['managed_hotel_id']?.toString(),
      managedHotelName: json['managed_hotel_name'],
      isActive: json['is_active'] ?? true,
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Konversi model ke Map JSON untuk dikirim ke API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'role': role.apiValue,
      'managed_hotel_id': managedHotelId,
      'managed_hotel_name': managedHotelName,
      'is_active': isActive,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// CopyWith untuk membuat instance baru dengan beberapa field diubah
  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    UserRole? role,
    String? managedHotelId,
    String? managedHotelName,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      managedHotelId: managedHotelId ?? this.managedHotelId,
      managedHotelName: managedHotelName ?? this.managedHotelName,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, role: ${role.displayName})';
  }
}
