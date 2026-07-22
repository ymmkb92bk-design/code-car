import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dtc_app/main.dart';

void main() {
  testWidgets('App shows the missing-config screen without a Supabase anon key', (WidgetTester tester) async {
    await tester.pumpWidget(const DtcApp());
    await tester.pump();

    expect(find.textContaining('SUPABASE_ANON_KEY'), findsOneWidget);
  });
}
