import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentavoz/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RentaVozApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
