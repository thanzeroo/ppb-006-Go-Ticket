import 'package:flutter/material.dart';

// =============================================================================
// FILE: lib/models/hotel_admin_model.dart
// RESPONSIBILITY: Data model untuk modul Administrator Pihak Hotel di Go Ticket.
// Mencakup:
// - RoomTypeData: data master kamar, okupansi, dan tarif weekday/weekend
// - StaffData: data staf hotel, roster shift, kontak, dan hak otorisasi
// - TransactionData: mutasi kas, reservasi kamar, dan metode pembayaran
// =============================================================================

/// Model ringkas tipe kamar, tingkat okupansi, dan tarif untuk Administrator Hotel.
class RoomTypeData {
  final String badge;
  final String? secondaryBadge;
  final String name;
  final String sub;
  final int totalUnit;
  final int terjual;
  final int occupancy;
  final String weekdayPrice;
  final String weekendPrice;
  final String weekendNote;
  final List<String> amenities;
  final int photoCount;
  final String imageUrl;

  const RoomTypeData({
    required this.badge,
    this.secondaryBadge,
    required this.name,
    required this.sub,
    required this.totalUnit,
    required this.terjual,
    required this.occupancy,
    required this.weekdayPrice,
    required this.weekendPrice,
    required this.weekendNote,
    required this.amenities,
    required this.photoCount,
    required this.imageUrl,
  });
}

/// Model data profil staf hotel, shift kerja, status tugas, dan hak akses.
class StaffData {
  final String name;
  final String id;
  final String role;
  final String roleKey;
  final String statusLabel;
  final Color statusBg;
  final Color statusFg;
  final Color onlineDotColor;
  final List<String> akses;
  final String wa;
  final String avatarUrl;
  final String? shift;
  final String? status;
  final String? email;
  final String? nik;

  const StaffData({
    required this.name,
    required this.id,
    required this.role,
    this.roleKey = 'front_office',
    String? statusLabel,
    this.statusBg = const Color(0xFFDCFCE7),
    this.statusFg = const Color(0xFF16A34A),
    this.onlineDotColor = const Color(0xFF22C55E),
    this.akses = const ['Check-in', 'Check-out'],
    this.wa = '081234567890',
    required this.avatarUrl,
    this.shift,
    this.status,
    this.email,
    this.nik,
  }) : statusLabel = statusLabel ?? status ?? 'Aktif Bertugas';
}

/// Model data mutasi transaksi kamar dan metode pembayaran di portal hotel.
class TransactionData {
  final String name;
  final String amount;
  final String room;
  final String code;
  final String method;
  final String time;

  const TransactionData({
    required this.name,
    required this.amount,
    required this.room,
    required this.code,
    required this.method,
    required this.time,
  });
}
