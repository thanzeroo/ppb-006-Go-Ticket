import 'package:flutter/material.dart';

import 'apps/pihak_user/main_pihak_user.dart';
import 'core/services/app_initializer.dart';

/// Entrypoint aplikasi go_ticket_user.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AppInitializer.init();
  } catch (e) {
    debugPrint('⚠️ [main] Inisialisasi mengalami kendala: $e');
  }
  runApp(const PihakUserApp());
}
