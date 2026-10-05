import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_ticket/main.dart';

void main() {
  testWidgets('App should render', (WidgetTester tester) async {
    await tester.pumpWidget(const GoTicketApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
