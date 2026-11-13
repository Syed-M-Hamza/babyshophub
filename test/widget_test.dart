import 'package:babyshophub/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('money formatter groups thousands', () {
    expect(formatMoney(1200), 'Rs 1,200');
    expect(formatMoney(0), 'Rs 0');
  });

  testWidgets('status label is readable', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Text('BabyShopHub')));
    expect(find.text('BabyShopHub'), findsOneWidget);
    expect(formatStatus('out_for_delivery'), 'Out For Delivery');
  });
}
