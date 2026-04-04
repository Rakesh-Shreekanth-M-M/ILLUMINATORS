import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astra/main.dart';

void main() {
  testWidgets('ASTRA app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AstraApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
