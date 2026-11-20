import 'package:flutter/material.dart';

import 'apps/pihak_go_ticket/main_pihak_go_ticket.dart';
import 'apps/pihak_hotel/main_pihak_hotel.dart';
import 'apps/pihak_user/main_pihak_user.dart';
import 'core/services/app_initializer.dart';

/// Entrypoint utama Go Ticket.
/// Ketiga aplikasi (Pihak User, Pihak Hotel, Pihak Go Ticket) sudah dipisah mandiri
/// tanpa menggunakan portal pemilihan perantara.
///
/// Cara menjalankan masing-masing aplikasi:
/// 1. Pihak User / Tamu (Default):
///    `flutter run` atau `flutter run -t lib/main_user.dart`
///
/// 2. Pihak Hotel (Mitra Penginapan):
///    `flutter run -t lib/main_hotel.dart` atau `flutter run --dart-define=APP=hotel`
///
/// 3. Pihak Go Ticket (Super Admin Platform):
///    `flutter run -t lib/main_go_ticket.dart` atau `flutter run --dart-define=APP=admin`
void main() async {
  await AppInitializer.init();

  const appTarget = String.fromEnvironment('APP', defaultValue: 'user');

  switch (appTarget.toLowerCase()) {
    case 'hotel':
      runApp(const PihakHotelApp());
      break;
    case 'admin':
    case 'go_ticket':
    case 'pihak_go_ticket':
      runApp(const PihakGoTicketApp());
      break;
    case 'user':
    case 'customer':
    default:
      runApp(const PihakUserApp());
      break;
  }
}
