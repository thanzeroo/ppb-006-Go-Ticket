import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/user_model.dart';
import '../utils/storage_helper.dart';
import 'mock_data.dart';
import 'supabase_service.dart';

/// Service autentikasi terpadu untuk semua peran di ekosistem Go Ticket.
/// Mendukung Supabase Auth dengan fallback seamless ke local mock session.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  // ---------------------------------------------------------------------------
  // INISIALISASI SESI DARI LOCAL STORAGE
  // ---------------------------------------------------------------------------
  Future<UserModel?> loadSavedSession() async {
    try {
      final token = await StorageHelper.getAccessToken();
      final roleStr = await StorageHelper.getUserRole();
      final userName = await StorageHelper.getUserName();
      final userEmail = await StorageHelper.getUserEmail();

      if (token != null && token.isNotEmpty) {
        final role = UserRoleExtension.fromApiString(roleStr ?? 'customer');
        _currentUser = UserModel(
          id: token,
          fullName: userName ?? 'Pengguna Go Ticket',
          email: userEmail ?? 'user@goticket.id',
          role: role,
          isVerified: true,
        );
        return _currentUser;
      }

      // Cek sesi Supabase jika client aktif
      final sbService = SupabaseService.instance;
      if (sbService.isReady && sbService.currentAuthUser != null) {
        final authUser = sbService.currentAuthUser!;
        final profileRes = await sbService
            .table(SupabaseConfig.tableProfiles)
            ?.select()
            .eq('id', authUser.id)
            .maybeSingle();

        if (profileRes != null) {
          _currentUser = UserModel.fromJson(profileRes);
        } else {
          _currentUser = UserModel(
            id: authUser.id,
            fullName: authUser.userMetadata?['full_name'] ?? 'Pengguna',
            email: authUser.email,
            phoneNumber: authUser.phone,
            role: UserRole.customer,
            isVerified: authUser.emailConfirmedAt != null,
          );
        }
        return _currentUser;
      }
    } catch (e) {
      debugPrint('⚠️ [AuthService] Gagal memuat sesi tersimpan: $e');
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // 1. LOGIN & REGISTER CUSTOMER
  // ---------------------------------------------------------------------------
  Future<UserModel> loginCustomer({
    required String email,
    required String password,
  }) async {
    final sbService = SupabaseService.instance;

    if (sbService.isReady && sbService.client != null) {
      try {
        final response = await sbService.client!.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        final user = response.user;
        if (user == null) throw Exception('User tidak ditemukan.');

        // Ambil profil detail dari database
        final profileRes = await sbService
            .table(SupabaseConfig.tableProfiles)
            ?.select()
            .eq('id', user.id)
            .maybeSingle();

        UserModel model;
        if (profileRes != null) {
          model = UserModel.fromJson(profileRes);
        } else {
          model = UserModel(
            id: user.id,
            fullName: user.userMetadata?['full_name'] ?? email.split('@')[0],
            email: user.email,
            phoneNumber: user.phone,
            role: UserRole.customer,
            isVerified: true,
          );
        }

        await _saveUserSession(model, response.session?.accessToken ?? user.id);
        _currentUser = model;
        return model;
      } on AuthException catch (e) {
        throw Exception(e.message);
      } catch (e) {
        debugPrint('⚠️ Supabase login gagal, fallback ke validasi lokal: $e');
      }
    }

    // Fallback Mock Validation
    await Future.delayed(const Duration(milliseconds: 600));
    final matched = MockData.users.firstWhere(
      (u) =>
          u.role == UserRole.customer &&
          (u.email?.toLowerCase() == email.trim().toLowerCase()),
      orElse: () => UserModel(
        id: 'usr-customer-${DateTime.now().millisecondsSinceEpoch}',
        fullName: email.split('@').first,
        email: email.trim(),
        role: UserRole.customer,
        isVerified: true,
      ),
    );

    await _saveUserSession(matched, 'mock-jwt-customer-token');
    _currentUser = matched;
    return matched;
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
        final response = await sbService.client!.auth.signUp(
          email: email.trim(),
          password: password,
          data: {
            'full_name': fullName.trim(),
            'phone': phone?.trim(),
            'role': 'customer',
          },
        );
        final user = response.user;
        if (user == null) throw Exception('Pendaftaran akun gagal.');

        final model = UserModel(
          id: user.id,
          fullName: fullName.trim(),
          email: email.trim(),
          phoneNumber: phone?.trim(),
          role: UserRole.customer,
          isVerified: false,
          createdAt: DateTime.now(),
        );

        // Simpan row ke tabel profiles jika Supabase table ready
        try {
          await sbService
              .table(SupabaseConfig.tableProfiles)
              ?.insert(model.toJson());
        } catch (_) {}

        await _saveUserSession(model, response.session?.accessToken ?? user.id);
        _currentUser = model;
        return model;
      } on AuthException catch (e) {
        throw Exception(e.message);
      } catch (e) {
        debugPrint('⚠️ Supabase register gagal, fallback ke mock: $e');
      }
    }

    // Fallback Mock
    await Future.delayed(const Duration(milliseconds: 700));
    final newModel = UserModel(
      id: 'usr-customer-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: email.trim(),
      phoneNumber: phone?.trim(),
      role: UserRole.customer,
      isVerified: true,
      createdAt: DateTime.now(),
    );
    MockData.users.add(newModel);
    await _saveUserSession(newModel, 'mock-jwt-customer-token');
    _currentUser = newModel;
    return newModel;
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
        // Cek login via Supabase Staff table / Auth
        final staffQuery = await sbService
            .table(SupabaseConfig.tableStaff)
            ?.select()
            .or('id.eq.$staffIdOrEmail,email.eq.$staffIdOrEmail')
            .maybeSingle();

        if (staffQuery != null) {
          final model = UserModel.fromJson(staffQuery);
          await _saveUserSession(model, 'sb-token-${model.id}');
          _currentUser = model;
          return model;
        }
      } catch (e) {
        debugPrint('⚠️ Supabase staff query gagal, fallback: $e');
      }
    }

    // Fallback Mock
    await Future.delayed(const Duration(milliseconds: 600));
    final matched = MockData.users.firstWhere(
      (u) =>
          u.role == role &&
          (u.id.toLowerCase() == staffIdOrEmail.toLowerCase() ||
              u.email?.toLowerCase() == staffIdOrEmail.toLowerCase()),
      orElse: () => UserModel(
        id: staffIdOrEmail,
        fullName: role == UserRole.adminHotel
            ? 'Administrator Hotel'
            : role == UserRole.maintenance
                ? 'Teknisi Maintenance'
                : 'Staff Front Office',
        email: staffIdOrEmail.contains('@') ? staffIdOrEmail : null,
        role: role,
        managedHotelId: 'htl-01',
        managedHotelName: 'The Grand Amora Resort & Spa',
        isVerified: true,
      ),
    );

    await _saveUserSession(matched, 'mock-jwt-${role.apiValue}-token');
    _currentUser = matched;
    return matched;
  }

  // ---------------------------------------------------------------------------
  // 3. LOGIN SUPER ADMIN (Platform Owner)
  // ---------------------------------------------------------------------------
  Future<UserModel> loginSuperAdmin({
    required String email,
    required String password,
    required String pin2FA,
  }) async {
    final sbService = SupabaseService.instance;

    if (sbService.isReady && sbService.client != null) {
      try {
        final res = await sbService.client!.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        if (res.user != null) {
          final adminUser = UserModel(
            id: res.user!.id,
            fullName: 'Super Admin Go Ticket',
            email: res.user!.email,
            role: UserRole.superAdmin,
            isVerified: true,
          );
          await _saveUserSession(
            adminUser,
            res.session?.accessToken ?? res.user!.id,
          );
          _currentUser = adminUser;
          return adminUser;
        }
      } catch (e) {
        debugPrint('⚠️ Supabase superadmin login gagal, fallback: $e');
      }
    }

    // Fallback Mock
    await Future.delayed(const Duration(milliseconds: 600));
    final admin = MockData.users.firstWhere(
      (u) => u.role == UserRole.superAdmin,
      orElse: () => const UserModel(
        id: 'usr-superadmin-01',
        fullName: 'Super Admin Master',
        email: 'admin.master@goticket.id',
        role: UserRole.superAdmin,
        isVerified: true,
      ),
    );

    await _saveUserSession(admin, 'mock-jwt-superadmin-token');
    _currentUser = admin;
    return admin;
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
    );
  }
}
