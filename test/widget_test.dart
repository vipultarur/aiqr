import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aiqr_app/main.dart';

void main() {
  testWidgets('App smoke test — AiarApp renders without crashing', (tester) async {
    await tester.pumpWidget(const AiarApp());
    expect(find.byType(MaterialApp), findsWidgets);
  });
}
