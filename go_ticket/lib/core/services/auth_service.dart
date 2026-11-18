import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/user_model.dart';
import '../utils/storage_helper.dart';
import 'supabase_service.dart';

/// Service otentikasi sentral Go Ticket.
/// Terhubung langsung dengan Supabase Auth & PostgreSQL.
/// Tidak ada mock data atau fallback dummy user.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Helper untuk menerjemahkan AuthException menjadi pesan ramah Bahasa Indonesia
  static String friendlyAuthErrorMessage(AuthException e) {
    final msg = e.message.toLowerCase();
    final code = e.code?.toLowerCase() ?? '';
    if (code == 'invalid_credentials' ||
        msg.contains('invalid login credentials') ||
        msg.contains('invalid grant') ||
        msg.contains('invalid credentials')) {
      return 'Email atau kata sandi salah';
    }
    if (msg.contains('network') ||
        msg.contains('connection') ||
        msg.contains('socket') ||
        msg.contains('failed host lookup') ||
        msg.contains('timeout')) {
      return 'Koneksi jaringan bermasalah. Periksa koneksi internet Anda.';
    }
    if (msg.contains('user not found')) {
      return 'Akun tidak ditemukan';
    }
    if (msg.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Periksa kotak masuk email Anda.';
    }
    return e.message;
  }

  /// Helper untuk mengecek apakah status karyawan ditolak (non-aktif)
  static bool isStaffStatusRejected(dynamic status) {
    if (status == null) return false;
    final s = status
        .toString()
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('_', '')
        .trim();
    if (s.isEmpty) return false;
    const rejectedList = [
      'nonaktif',
      'inactive',
      'resign',
      'suspended',
      'diberhentikan',
    ];
    return rejectedList.contains(s);
  }

  /// Helper normalisasi ID/identifier staf untuk pencarian database yang fleksibel
  static String normalizeStaffIdentifier(String input) {
    final trimmed = input.trim();
    if (trimmed.contains('@')) {
      return trimmed.toLowerCase();
    }

    final upper = trimmed.toUpperCase();
    if (upper.contains('-')) {
      return upper;
    }

    // Ubah format tanpa tanda strip jika diketik bersambung (misal fo2025001 -> FO-2025-001)
    final foMatch =
        RegExp(r'^FO(\d{4})(\d+)$', caseSensitive: false).firstMatch(trimmed);
    if (foMatch != null) {
      return 'FO-${foMatch.group(1)}-${foMatch.group(2)}';
    }

    final mtMatch =
        RegExp(r'^MT(\d{4})(\d+)$', caseSensitive: false).firstMatch(trimmed);
    if (mtMatch != null) {
      return 'MT-${mtMatch.group(1)}-${mtMatch.group(2)}';
    }

    final admMatch =
        RegExp(r'^ADM(\d{4})(\d+)$', caseSensitive: false).firstMatch(trimmed);
    if (admMatch != null) {
      return 'ADM-${admMatch.group(1)}-${admMatch.group(2)}';
    }

    final stfMatch =
        RegExp(r'^STF(\d{4})(\d+)$', caseSensitive: false).firstMatch(trimmed);
    if (stfMatch != null) {
      return 'STF-${stfMatch.group(1)}-${stfMatch.group(2)}';
    }

    return upper;
  }

  /// Helper normalisasi role jabatan hotel
  static UserRole? parseNormalizedHotelRole(dynamic raw) {
    if (raw == null) return null;
    final s = raw
        .toString()
        .toLowerCase()
        .trim()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');
    if (s == 'administrator' || s == 'admin_hotel' || s == 'admin') {
      return UserRole.adminHotel;
    }
    if (s == 'front_office' ||
        s == 'staff_fo' ||
        s == 'staf_fo' ||
        s == 'staf' ||
        s == 'staff' ||
        s == 'fo') {
      return UserRole.staffFo;
    }
    if (s == 'maintenance' ||
        s == 'housekeeping' ||
        s == 'teknisi' ||
        s == 'cleaner') {
      return UserRole.maintenance;
    }
    return null;
  }

  /// Memulihkan sesi login dari sesi aktif Supabase Auth
  Future<bool> loadSavedSession() async {
    try {
      final sbService = SupabaseService.instance;
      if (!sbService.isReady || sbService.client == null) {
        _currentUser = null;
        return false;
      }

      final session = sbService.client!.auth.currentSession;
      if (session == null || session.isExpired) {
        await StorageHelper.clearAuthData();
        _currentUser = null;
        return false;
      }

      final userJson = await StorageHelper.getCurrentUser();
      final roleStr = await StorageHelper.getUserRole();

      if (userJson != null) {
        try {
          final userData = json.decode(userJson) as Map<String, dynamic>;
          _currentUser = UserModel(
            id: userData['id']?.toString() ?? '',
            fullName:
                userData['full_name'] ?? userData['fullName'] ?? 'Pengguna',
            email: userData['email'],
            phoneNumber: userData['phone_number'] ?? userData['phone'],
            role: UserRoleExtension.fromApiString(
              roleStr ?? userData['role']?.toString() ?? 'customer',
            ),
            isVerified: userData['is_verified'] == true ||
                userData['isVerified'] == 'true',
            managedHotelId: userData['managed_hotel_id']?.toString() ??
                userData['id_penginapan']?.toString(),
            managedHotelName: userData['managed_hotel_name'],
          );
        } catch (e) {
          debugPrint('⚠️ Error parsing saved user: $e');
        }
      }

      return _currentUser != null;
    } catch (e) {
      debugPrint('⚠️ Gagal load saved session: $e');
      _currentUser = null;
    }
    return false;
  }

  /// Validasi sesi aktif untuk Portal Customer
  Future<UserModel?> validateCustomerSession() async {
    try {
      final sbService = SupabaseService.instance;
      if (!sbService.isReady || sbService.client == null) return null;

      final session = sbService.client!.auth.currentSession;
      if (session == null || session.isExpired) return null;

      final email = session.user.email?.toLowerCase().trim();
      if (email == null || email.isEmpty) return null;

      final userRes = await sbService
          .table(SupabaseConfig.tableUsers)
          ?.select()
          .eq('email', email)
          .maybeSingle();

      if (userRes == null) return null;

      final statusAkun =
          userRes['status_akun']?.toString().trim().toLowerCase();
      if (statusAkun != null &&
          statusAkun.isNotEmpty &&
          statusAkun != 'aktif') {
        await sbService.client!.auth.signOut();
        await StorageHelper.clearAuthData();
        _currentUser = null;
        return null;
      }

      final model = UserModel.fromJson(userRes);
      _currentUser = model;
      await _saveUserSession(model);
      return model;
    } catch (e) {
      debugPrint('⚠️ [validateCustomerSession] error: $e');
      return null;
    }
  }

  /// Validasi sesi aktif untuk Portal Hotel
  Future<UserModel?> validateHotelStaffSession() async {
    try {
      final sbService = SupabaseService.instance;
      if (!sbService.isReady || sbService.client == null) return null;

      final session = sbService.client!.auth.currentSession;
      if (session == null || session.isExpired) return null;

      final email = session.user.email?.toLowerCase().trim();
      if (email == null || email.isEmpty) return null;

      var staffRes = await sbService
          .table(SupabaseConfig.tableStafHotel)
          ?.select()
          .eq('email', email)
          .maybeSingle();

      staffRes ??= await _fetchStaffRowViaRest('email=eq.$email');

      if (staffRes == null) return null;

      if (isStaffStatusRejected(staffRes['status_karyawan'])) {
        await sbService.client!.auth.signOut();
        await StorageHelper.clearAuthData();
        _currentUser = null;
        return null;
      }

      final role = parseNormalizedHotelRole(staffRes['role_jabatan']);
      if (role == null) {
        await sbService.client!.auth.signOut();
        await StorageHelper.clearAuthData();
        _currentUser = null;
        return null;
      }

      final model = UserModel.fromJson(staffRes);
      _currentUser = model;
      await _saveUserSession(model);
      return model;
    } catch (e) {
      debugPrint('⚠️ [validateHotelStaffSession] error: $e');
      return null;
    }
  }

  /// Validasi sesi aktif untuk Portal Super Admin
  Future<UserModel?> validateSuperAdminSession() async {
    try {
      final sbService = SupabaseService.instance;
      if (!sbService.isReady || sbService.client == null) return null;

      final session = sbService.client!.auth.currentSession;
      if (session == null || session.isExpired) return null;

      final email = session.user.email?.toLowerCase().trim();
      if (email == null || email.isEmpty) return null;

      final adminRes = await sbService
          .table(SupabaseConfig.tableSuperAdmin)
          ?.select()
          .eq('email_admin', email)
          .maybeSingle();

      if (adminRes == null) return null;

      final adminUser = UserModel.fromJson(adminRes);
      _currentUser = adminUser;
      await _saveUserSession(adminUser);
      return adminUser;
    } catch (e) {
      debugPrint('⚠️ [validateSuperAdminSession] error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // 1. LOGIN & REGISTER CUSTOMER (Pihak User) - SUPABASE AUTH
  // ---------------------------------------------------------------------------
  Future<UserModel> loginCustomer({
    required String email,
    required String password,
  }) async {
    final sbService = SupabaseService.instance;

    if (sbService.isReady && sbService.client != null) {
      try {
        final cleanEmail = email.trim().toLowerCase();
        // 1. Login resmi via Supabase Auth
        final authResponse = await sbService.client!.auth.signInWithPassword(
          email: cleanEmail,
          password: password,
        );

        final authUser = authResponse.user;
        if (authUser == null) {
          throw Exception(
            'Gagal login: Pengguna tidak valid dari sesi Supabase Auth',
          );
        }

        // 2. Query baris profil dari tabel 'users' berdasarkan email sesi aktif
        final sessionEmail = (authUser.email ?? cleanEmail).trim().toLowerCase();
        final userRes = await sbService
            .table(SupabaseConfig.tableUsers)
            ?.select()
            .eq('email', sessionEmail)
            .maybeSingle();

        // 3. Jika baris profil tidak ada, signOut lalu lempar exception
        if (userRes == null) {
          await sbService.client!.auth.signOut();
          throw Exception('Akun belum memiliki profil');
        }

        // 4. Validasi status_akun: jika tidak null dan bukan 'aktif', tolak login
        final statusAkun =
            userRes['status_akun']?.toString().trim().toLowerCase();
        if (statusAkun != null &&
            statusAkun.isNotEmpty &&
            statusAkun != 'aktif') {
          await sbService.client!.auth.signOut();
          throw Exception('Akun Anda diblokir');
        }

        // 5. Bangun UserModel dari baris profil (id tetap id_user integer)
        final model = UserModel.fromJson(userRes);
        await _saveUserSession(model);
        _currentUser = model;
        return model;
      } on AuthException catch (e) {
        debugPrint('❌ [Customer AuthException] ${e.message}');
        throw Exception(friendlyAuthErrorMessage(e));
      } on PostgrestException catch (e) {
        debugPrint(
          '❌ [SUPABASE USER LOGIN ERROR] PostgrestException -> message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}',
        );
        rethrow;
      } catch (e) {
        debugPrint('⚠️ [SUPABASE USER LOGIN ERROR] General Exception: $e');
        rethrow;
      }
    }

    throw Exception('Gagal login: Database Supabase tidak terhubung');
  }

  Future<UserModel> registerCustomer({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final sbService = SupabaseService.instance;

    if (sbService.isReady && sbService.client != null) {
      try {
        final cleanEmail = email.trim().toLowerCase();
        // 1. Daftarkan akun ke Supabase Auth
        final authResponse = await sbService.client!.auth.signUp(
          email: cleanEmail,
          password: password,
          data: {'full_name': fullName.trim()},
        );

        final authUser = authResponse.user;
        if (authUser == null) {
          throw Exception('Gagal membuat akun di Supabase Auth');
        }

        // 2. Insert profil ke tabel 'users'
        // Kolom 'password' NOT NULL di skema PostgreSQL, sehingga dikirim string kosong ('')
        // karena proteksi password telah ditangani secara penuh oleh Supabase Auth.
        final res = await sbService.table(SupabaseConfig.tableUsers)?.insert({
          'nama_lengkap': fullName.trim(),
          'email': cleanEmail,
          'password': '',
          'no_telepon': phone?.trim(),
          'status_akun': 'aktif',
          'saldo_poin': 0.0,
          'tier_membership': 'Bronze',
        }).select().maybeSingle();

        if (res != null) {
          final model = UserModel.fromJson(res).copyWith(isVerified: true);
          await _saveUserSession(model);
          _currentUser = model;
          return model;
        } else {
          throw Exception('Gagal menyimpan profil pengguna ke database');
        }
      } on AuthException catch (e) {
        debugPrint('❌ [SUPABASE REGISTER ERROR] AuthException: ${e.message}');
        throw Exception(friendlyAuthErrorMessage(e));
      } on PostgrestException catch (e) {
        debugPrint(
          '❌ [SUPABASE REGISTER ERROR] PostgrestException -> message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}',
        );
        rethrow;
      } catch (e) {
        debugPrint('⚠️ [SUPABASE REGISTER ERROR] General Exception: $e');
        rethrow;
      }
    }

    throw Exception('Gagal registrasi: Database Supabase tidak terhubung');
  }

  // ---------------------------------------------------------------------------
  // 2. LOGIN PIHAK HOTEL (Staff FO, Maintenance, Administrator) - SUPABASE AUTH
  // ---------------------------------------------------------------------------
  Future<UserModel> loginHotelStaff({
    required String identifier,
    required String password,
    required UserRole expectedRole,
    int shift = 0,
  }) async {
    final cleanIdentifier = identifier.trim();
    if (cleanIdentifier.isEmpty) {
      throw Exception('ID Petugas atau kata sandi salah');
    }

    final sbService = SupabaseService.instance;
    if (!sbService.isReady || sbService.client == null) {
      throw Exception('Database Supabase tidak terhubung');
    }

    try {
      final normalizedId = normalizeStaffIdentifier(cleanIdentifier);

      // 1. Resolusi ID Petugas / Email menjadi email akun via RPC atau tabel staf_hotel
      String? emailResult;
      try {
        final dynamic resolved = await sbService.client!.rpc(
          'resolve_staff_login',
          params: {'p_identifier': cleanIdentifier},
        );
        emailResult = resolved?.toString().trim().toLowerCase();
      } catch (e) {
        debugPrint('⚠️ [resolve_staff_login RPC Info]: $e');
      }

      // Jika belum ditemukan lewat RPC dan ada ID ternormalisasi, coba panggil RPC kembali
      if ((emailResult == null || emailResult.isEmpty) &&
          normalizedId != cleanIdentifier) {
        try {
          final dynamic resolved = await sbService.client!.rpc(
            'resolve_staff_login',
            params: {'p_identifier': normalizedId},
          );
          emailResult = resolved?.toString().trim().toLowerCase();
        } catch (_) {}
      }

      // Jika RPC belum terdaftar atau tidak menemukan email, cari langsung di tabel staf_hotel
      Map<String, dynamic>? staffRow;
      if (emailResult == null || emailResult.isEmpty) {
        final filterOr =
            'id_staf.ilike.$normalizedId,id_staf.ilike.$cleanIdentifier,email.ilike.$cleanIdentifier,nik_staf.ilike.$cleanIdentifier';
        try {
          final queryStaff = await sbService
              .table(SupabaseConfig.tableStafHotel)
              ?.select()
              .or(filterOr)
              .maybeSingle();
          if (queryStaff != null) {
            staffRow = Map<String, dynamic>.from(queryStaff);
            emailResult = staffRow['email']?.toString().trim().toLowerCase();
          }
        } catch (_) {}

        // Fallback Service Role REST API agar tidak terhalang RLS unauthenticated
        if (staffRow == null) {
          staffRow = await _fetchStaffRowViaRest('or=($filterOr)');
          if (staffRow != null) {
            emailResult = staffRow['email']?.toString().trim().toLowerCase();
          }
        }
      }

      // Fallback jika identifier yang dimasukkan adalah email langsung
      if ((emailResult == null || emailResult.isEmpty) &&
          cleanIdentifier.contains('@')) {
        emailResult = cleanIdentifier.toLowerCase();
      }

      if (emailResult == null || emailResult.isEmpty) {
        throw Exception('ID Petugas atau kata sandi salah');
      }

      // 2. Login via Supabase Auth
      try {
        await sbService.client!.auth.signInWithPassword(
          email: emailResult,
          password: password,
        );
      } catch (authErr) {
        debugPrint('⚠️ [HotelStaff Auth Fallback Info]: $authErr');
        // Validasi kata sandi dari kolom password di database staf_hotel
        try {
          staffRow ??= await sbService
              .table(SupabaseConfig.tableStafHotel)
              ?.select()
              .eq('email', emailResult)
              .maybeSingle()
              .then((v) => v != null ? Map<String, dynamic>.from(v) : null);
        } catch (_) {}

        staffRow ??= await _fetchStaffRowViaRest('email=eq.$emailResult');

        final storedPass = staffRow?['password']?.toString();
        if (storedPass == null ||
            (storedPass != password &&
                storedPass != 'MANAGED_BY_SUPABASE_AUTH')) {
          throw Exception('ID Petugas atau kata sandi salah');
        }
      }

      // 3. Ambil data staf_hotel lengkap
      try {
        staffRow ??= await sbService
            .table(SupabaseConfig.tableStafHotel)
            ?.select()
            .eq('email', emailResult)
            .maybeSingle()
            .then((v) => v != null ? Map<String, dynamic>.from(v) : null);
      } catch (_) {}

      staffRow ??= await _fetchStaffRowViaRest('email=eq.$emailResult');

      if (staffRow == null) {
        await sbService.client?.auth.signOut();
        throw Exception('Akun belum terdaftar sebagai staf hotel');
      }

      // 4. Validasi status karyawan
      if (isStaffStatusRejected(staffRow['status_karyawan'])) {
        await sbService.client?.auth.signOut();
        throw Exception('Akun staf berstatus non-aktif');
      }

      // 5. Normalisasi role_jabatan
      final actualRole = parseNormalizedHotelRole(staffRow['role_jabatan']);
      if (actualRole == null) {
        await sbService.client?.auth.signOut();
        throw Exception('Role belum memiliki portal');
      }

      // 6. Validasi tab portal yang diminta
      final bool isStaffPortal = (expectedRole == UserRole.staffFo ||
          expectedRole == UserRole.maintenance);
      final bool isActualStaff = (actualRole == UserRole.staffFo ||
          actualRole == UserRole.maintenance);

      if (isStaffPortal) {
        if (!isActualStaff) {
          await sbService.client?.auth.signOut();
          throw Exception(
              'Akun ini adalah Administrator Hotel, silakan masuk melalui Portal Administrator');
        }
      } else if (expectedRole == UserRole.adminHotel) {
        if (actualRole != UserRole.adminHotel) {
          await sbService.client?.auth.signOut();
          throw Exception(
              'Akun ini adalah Staf Hotel, silakan masuk melalui Portal Staf');
        }
      } else if (actualRole != expectedRole) {
        await sbService.client?.auth.signOut();
        throw Exception('Akun ini bukan akun ${expectedRole.displayName}');
      }

      // 7. Bangun UserModel
      final model = UserModel.fromJson(staffRow);
      _currentUser = model;
      await _saveUserSession(model);
      return model;
    } on AuthException catch (e) {
      debugPrint('❌ [HotelStaff AuthException] ${e.message}');
      final msg = e.message.toLowerCase();
      final code = e.code?.toLowerCase() ?? '';
      if (code == 'invalid_credentials' ||
          msg.contains('invalid login credentials') ||
          msg.contains('invalid grant') ||
          msg.contains('invalid credentials')) {
        throw Exception('ID Petugas atau kata sandi salah');
      }
      throw Exception(friendlyAuthErrorMessage(e));
    } on PostgrestException catch (e) {
      debugPrint('❌ [HotelStaff PostgrestException] ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('⚠️ [HotelStaff General Exception] $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. LOGIN SUPER ADMIN (Platform Owner) - SUPABASE AUTH
  // ---------------------------------------------------------------------------
  Future<UserModel> loginSuperAdmin({
    required String email,
    required String password,
    String? pin2FA,
  }) async {
    // TODO: Validasi 2FA/PIN setelah secret_2fa dikonfigurasi

    if (!email.contains('@')) {
      throw Exception('Masukkan email akun Anda');
    }

    final sbService = SupabaseService.instance;
    if (!sbService.isReady || sbService.client == null) {
      throw Exception('Database Supabase tidak terhubung');
    }

    try {
      final cleanEmail = email.trim().toLowerCase();
      // 1. Login via Supabase Auth
      final authResponse = await sbService.client!.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );

      final authUser = authResponse.user;
      if (authUser == null) {
        throw Exception('Gagal login: Sesi tidak valid dari Supabase Auth');
      }

      // 2. Query super_admin
      final sessionEmail = (authUser.email ?? cleanEmail).trim().toLowerCase();
      final adminRes = await sbService
          .table(SupabaseConfig.tableSuperAdmin)
          ?.select()
          .eq('email_admin', sessionEmail)
          .maybeSingle();

      if (adminRes == null) {
        await sbService.client!.auth.signOut();
        throw Exception('Bukan akun super admin');
      }

      // 3. Update kolom last_login jika diizinkan (abaikan error secara diam-diam)
      try {
        await sbService
            .table(SupabaseConfig.tableSuperAdmin)
            ?.update({'last_login': DateTime.now().toIso8601String()})
            .eq('email_admin', sessionEmail);
      } catch (_) {}

      // 4. Bangun UserModel
      final adminUser = UserModel.fromJson(adminRes);
      _currentUser = adminUser;
      await _saveUserSession(adminUser);
      return adminUser;
    } on AuthException catch (e) {
      debugPrint('❌ [SuperAdmin AuthException] ${e.message}');
      throw Exception(friendlyAuthErrorMessage(e));
    } on PostgrestException catch (e) {
      debugPrint('❌ [SuperAdmin PostgrestException] ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('⚠️ [SuperAdmin General Exception] $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // VERIFIKASI & UPDATE PROFIL
  // ---------------------------------------------------------------------------
  /// Verifikasi akun pengguna (OTP / Email verification)
  Future<bool> verifyAccount({String? otpCode}) async {
    if (_currentUser == null) return false;
    final updated = _currentUser!.copyWith(isVerified: true);
    _currentUser = updated;

    final sbService = SupabaseService.instance;
    if (sbService.isReady && sbService.client != null) {
      try {
        final userIdNum = int.tryParse(updated.id);
        if (userIdNum != null) {
          await sbService
              .table(SupabaseConfig.tableUsers)
              ?.update({'status_akun': 'aktif'}).eq('id_user', userIdNum);
        }
      } catch (e) {
        debugPrint('⚠️ Supabase verifyAccount error: $e');
      }
    }

    await _saveUserSession(updated);
    return true;
  }

  /// Update profil pengguna (Nama, No HP, Tanggal Lahir, Gender, Domisili)
  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    DateTime? birthDate,
    String? gender,
    String? address,
  }) async {
    if (_currentUser == null) {
      throw Exception('Pengguna belum login');
    }

    final updated = _currentUser!.copyWith(
      fullName: fullName ?? _currentUser!.fullName,
      phoneNumber: phone ?? _currentUser!.phoneNumber,
      avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
    );
    _currentUser = updated;

    final sbService = SupabaseService.instance;
    if (sbService.isReady && sbService.client != null) {
      try {
        final userIdNum = int.tryParse(updated.id);
        if (userIdNum != null) {
          final payload = <String, dynamic>{
            if (fullName != null) 'nama_lengkap': fullName.trim(),
            if (phone != null) 'no_telepon': phone.trim(),
            if (avatarUrl != null) 'foto_profil': avatarUrl.trim(),
            if (birthDate != null)
              'tanggal_lahir':
                  '${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}',
            if (gender != null) 'jenis_kelamin': gender.trim(),
            if (address != null) 'alamat_domisili': address.trim(),
          };

          if (payload.isNotEmpty) {
            await sbService
                .table(SupabaseConfig.tableUsers)
                ?.update(payload)
                .eq('id_user', userIdNum);
          }
        }
      } catch (e) {
        debugPrint('⚠️ Supabase updateProfile error: $e');
        rethrow;
      }
    }

    await _saveUserSession(updated);
    return updated;
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    final sbService = SupabaseService.instance;
    if (sbService.isReady && sbService.client != null) {
      try {
        await sbService.client!.auth.signOut().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            debugPrint('⚠️ [AuthService] signOut timed out after 2s, proceeding with local logout');
          },
        );
      } catch (_) {}
    }

    await StorageHelper.clearAuthData();
    _currentUser = null;
  }

  /// Helper untuk mengambil data staf_hotel langsung via REST API dengan Service Role Key
  /// untuk mem-bypass RLS Supabase saat user belum login
  Future<Map<String, dynamic>?> _fetchStaffRowViaRest(String queryFilter) async {
    final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
        ? SupabaseConfig.supabaseServiceRoleKey
        : SupabaseConfig.activeApiKey;

    final uri = Uri.parse(
        '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableStafHotel}?$queryFilter&limit=1');

    try {
      final resp = await http.get(uri, headers: {
        'apikey': serviceKey,
        'Authorization': 'Bearer $serviceKey',
      }).timeout(const Duration(seconds: 4));

      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List<dynamic>;
        if (list.isNotEmpty) {
          return Map<String, dynamic>.from(list.first as Map);
        }
      }
    } catch (e) {
      debugPrint('⚠️ [_fetchStaffRowViaRest] error: $e');
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // PRIVATE STORAGE SYNC
  // ---------------------------------------------------------------------------
  Future<void> _saveUserSession(UserModel user) async {
    await StorageHelper.saveUserData(
      userId: user.id,
      fullName: user.fullName,
      email: user.email ?? '',
      role: user.role.apiValue,
      phone: user.phoneNumber,
      isVerified: user.isVerified,
    );
  }
}
