import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:go_ticket_hotel/apps/pihak_hotel/main_pihak_hotel.dart';

void main() {
  testWidgets('PihakHotelApp should render', (WidgetTester tester) async {
    await tester.pumpWidget(const PihakHotelApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
