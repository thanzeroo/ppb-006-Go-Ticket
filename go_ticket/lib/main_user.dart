import 'package:flutter/material.dart';

import 'apps/pihak_user/main_pihak_user.dart';
import 'core/services/app_initializer.dart';

/// Entrypoint khusus aplikasi Pihak User (Customer / Tamu).
/// Jalankan dengan:
/// `flutter run -t lib/main_user.dart`
void main() async {
  await AppInitializer.init();
  runApp(const PihakUserApp());
}

