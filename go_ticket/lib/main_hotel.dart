import 'package:flutter/material.dart';

import 'apps/pihak_hotel/main_pihak_hotel.dart';
import 'core/services/app_initializer.dart';

/// Entrypoint khusus aplikasi Pihak Hotel (Front Office, Maintenance, Admin Hotel).
/// Jalankan dengan:
/// `flutter run -t lib/main_hotel.dart`
void main() async {
  await AppInitializer.init();
  runApp(const PihakHotelApp());
}

