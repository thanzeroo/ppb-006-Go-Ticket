import 'package:flutter/material.dart';

import 'apps/pihak_hotel/main_pihak_hotel.dart';
import 'core/services/app_initializer.dart';

/// Entrypoint aplikasi go_ticket_hotel.
void main() async {
  await AppInitializer.init();
  runApp(const PihakHotelApp());
}
