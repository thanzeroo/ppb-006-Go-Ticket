import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:go_ticket_user/apps/pihak_user/main_pihak_user.dart';

void main() {
  testWidgets('PihakUserApp should render', (WidgetTester tester) async {
    await tester.pumpWidget(const PihakUserApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
