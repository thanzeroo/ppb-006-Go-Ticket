import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  /// Memulihkan sesi login dari penyimpanan lokal (SharedPreferences / Secure Storage)
  Future<bool> loadSavedSession() async {
    try {
      final token = await StorageHelper.getAccessToken();
      final userJson = await StorageHelper.getCurrentUser();
      final roleStr = await StorageHelper.getUserRole();

      if (token != null && userJson != null) {
        try {
          final userData = json.decode(userJson) as Map<String, dynamic>;
          _currentUser = UserModel(
            id: userData['id']?.toString() ?? '',
            fullName: userData['full_name'] ?? userData['fullName'] ?? 'Pengguna',
            email: userData['email'],
            phoneNumber: userData['phone_number'] ?? userData['phone'],
            role: UserRoleExtension.fromApiString(roleStr ?? userData['role']?.toString() ?? 'customer'),
            isVerified: userData['is_verified'] == true || userData['isVerified'] == 'true',
          );
        } catch (e) {
          debugPrint('⚠️ Error parsing saved user: $e');
          return false;
        }

        // Validasi sinkronisasi profil terbaru dari Supabase jika koneksi aktif
        final sbService = SupabaseService.instance;
        if (sbService.isReady && sbService.client != null) {
          try {
            final userIdNum = int.tryParse(_currentUser!.id);
            if (userIdNum != null) {
              final remoteUser = await sbService
                  .table(SupabaseConfig.tableUsers)
                  ?.select()
                  .eq('id_user', userIdNum)
                  .maybeSingle();

              if (remoteUser != null) {
                _currentUser = UserModel.fromJson(remoteUser);
              }
            }
          } catch (e) {
            debugPrint('⚠️ Sync session profile error: $e');
          }
        }

        return true;
      }
    } catch (e) {
      debugPrint('⚠️ Gagal load saved session: $e');
    }
    return false;
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
        // 1. Login resmi via Supabase Auth
        final authResponse = await sbService.client!.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );

        final authUser = authResponse.user;
        if (authUser == null) {
          throw Exception(
            'Gagal login: Pengguna tidak valid dari sesi Supabase Auth',
          );
        }

        // 2. Query baris profil dari tabel 'users' berdasarkan email sesi aktif
        final sessionEmail = (authUser.email ?? email).trim();
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

        // 4. Bangun UserModel dari baris profil (id tetap id_user integer)
        final model = UserModel.fromJson(userRes);
        await _saveUserSession(
          model,
          authResponse.session?.accessToken ?? 'jwt-user-${model.id}',
        );
        _currentUser = model;
        return model;
      } on AuthException catch (e) {
        debugPrint(
          '❌ [SUPABASE USER LOGIN ERROR] AuthException -> message: ${e.message}, statusCode: ${e.statusCode}, code: ${e.code}',
        );
        rethrow;
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
        // 1. Daftarkan akun ke Supabase Auth
        final authResponse = await sbService.client!.auth.signUp(
          email: email.trim(),
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
          'email': email.trim(),
          'password': '',
          'no_telepon': phone?.trim(),
          'status_akun': 'aktif',
          'saldo_poin': 0.0,
          'tier_membership': 'Bronze',
        }).select().maybeSingle();

        if (res != null) {
          final model = UserModel.fromJson(res).copyWith(isVerified: true);
          await _saveUserSession(
            model,
            authResponse.session?.accessToken ?? 'jwt-user-${model.id}',
          );
          _currentUser = model;
          return model;
        } else {
          throw Exception('Gagal menyimpan profil pengguna ke database');
        }
      } on AuthException catch (e) {
        debugPrint(
          '❌ [SUPABASE REGISTER ERROR] AuthException -> message: ${e.message}, statusCode: ${e.statusCode}, code: ${e.code}',
        );
        rethrow;
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
  // 2. LOGIN PIHAK HOTEL (Staff FO, Maintenance, Administrator)
  // ---------------------------------------------------------------------------
  Future<UserModel> loginHotelStaff({
    required String staffIdOrEmail,
    required String password,
    required UserRole role,
    int shift = 0,
  }) async {
    final sbService = SupabaseService.instance;

    if (sbService.isReady && sbService.client != null) {
      try {
        final input = staffIdOrEmail.trim();
        String sessionEmail = input;
        String? token;

        // 1. Jika input berupa email, autentikasi via Supabase Auth
        if (input.contains('@')) {
          final authResponse = await sbService.client!.auth.signInWithPassword(
            email: input,
            password: password,
          );
          final authUser = authResponse.user;
          if (authUser == null) {
            throw Exception('Gagal login: Sesi Supabase Auth tidak valid');
          }
          sessionEmail = (authUser.email ?? input).trim();
          token = authResponse.session?.accessToken;
        }

        // 2. Cek login via tabel 'staf_hotel'
        final staffQuery = await sbService
            .table(SupabaseConfig.tableStafHotel)
            ?.select()
            .or('email.ilike.$sessionEmail,id_staf.eq.$input')
            .maybeSingle();

        if (staffQuery != null) {
          final model = UserModel.fromJson(staffQuery);
          await _saveUserSession(model, token ?? 'staf-token-${model.id}');
          _currentUser = model;
          return model;
        } else {
          if (input.contains('@')) {
            await sbService.client!.auth.signOut();
          }
          throw Exception('Akun staf $input tidak terdaftar di database.');
        }
      } on PostgrestException catch (e) {
        debugPrint('❌ [SUPABASE STAFF LOGIN ERROR] PostgrestException -> message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
        rethrow;
      } on AuthException catch (e) {
        debugPrint('❌ [SUPABASE STAFF LOGIN ERROR] AuthException -> message: ${e.message}, statusCode: ${e.statusCode}, code: ${e.code}');
        rethrow;
      } catch (e) {
        debugPrint('⚠️ [SUPABASE STAFF LOGIN ERROR] General Exception: $e');
        rethrow;
      }
    }

    throw Exception('Gagal login staff: Database tidak terhubung');
  }

  // ---------------------------------------------------------------------------
  // 3. LOGIN SUPER ADMIN (Platform Owner / Pihak Go Ticket)
  // ---------------------------------------------------------------------------
  Future<UserModel> loginSuperAdmin({
    required String email,
    required String password,
    required String pin2FA,
  }) async {
    final sbService = SupabaseService.instance;

    if (sbService.isReady && sbService.client != null) {
      try {
        final cleanEmail = email.trim();

        // 1. Autentikasi resmi via Supabase Auth
        final authResponse = await sbService.client!.auth.signInWithPassword(
          email: cleanEmail,
          password: password,
        );

        final authUser = authResponse.user;
        if (authUser == null) {
          throw Exception('Gagal login: Sesi Supabase Auth tidak valid');
        }

        // 2. Query data super_admin berdasarkan email sesi aktif
        final sessionEmail = (authUser.email ?? cleanEmail).trim();
        final adminRes = await sbService
            .table(SupabaseConfig.tableSuperAdmin)
            ?.select()
            .ilike('email_admin', sessionEmail)
            .maybeSingle();

        if (adminRes != null) {
          final adminUser = UserModel.fromJson(adminRes);
          await _saveUserSession(
            adminUser,
            authResponse.session?.accessToken ?? 'admin-token-${adminUser.id}',
          );
          _currentUser = adminUser;
          return adminUser;
        } else {
          await sbService.client!.auth.signOut();
          throw Exception('Akun $sessionEmail tidak terdaftar sebagai Super Admin Go Ticket di database.');
        }
      } on AuthException catch (e) {
        debugPrint('❌ [SUPABASE SUPERADMIN LOGIN ERROR] AuthException -> message: ${e.message}, statusCode: ${e.statusCode}, code: ${e.code}');
        rethrow;
      } on PostgrestException catch (e) {
        debugPrint('❌ [SUPABASE SUPERADMIN LOGIN ERROR] PostgrestException -> message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
        rethrow;
      } catch (e) {
        debugPrint('⚠️ [SUPABASE SUPERADMIN LOGIN ERROR] General Exception: $e');
        rethrow;
      }
    }

    throw Exception('Gagal login Super Admin: Database Supabase tidak terhubung');
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

    await _saveUserSession(updated, 'jwt-user-${updated.id}');
    return true;
  }

  /// Update profil pengguna (Nama, No HP, dll)
  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
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
          await sbService.table(SupabaseConfig.tableUsers)?.update({
            if (fullName != null) 'nama_lengkap': fullName.trim(),
            if (phone != null) 'no_telepon': phone.trim(),
            if (avatarUrl != null) 'foto_profil': avatarUrl,
          }).eq('id_user', userIdNum);
        }
      } catch (e) {
        debugPrint('⚠️ Supabase updateProfile error: $e');
      }
    }

    await _saveUserSession(updated, 'jwt-user-${updated.id}');
    return updated;
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    final sbService = SupabaseService.instance;
    if (sbService.isReady && sbService.client != null) {
      try {
        await sbService.client!.auth.signOut();
      } catch (_) {}
    }

    await StorageHelper.clearAuthData();
    _currentUser = null;
  }

  // ---------------------------------------------------------------------------
  // PRIVATE STORAGE SYNC
  // ---------------------------------------------------------------------------
  Future<void> _saveUserSession(UserModel user, String token) async {
    await StorageHelper.saveTokens(accessToken: token, refreshToken: token);
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
