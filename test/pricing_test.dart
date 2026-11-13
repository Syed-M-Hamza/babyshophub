import 'package:babyshophub/utils/pricing.dart';
import 'package:babyshophub/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unit price rounds half up to whole rupees', () {
    expect(Pricing.unitPrice(199, 10), 179);
    expect(Pricing.unitPrice(1000, 0), 1000);
    expect(Pricing.unitPrice(2000, 25), 1500);
  });

  test('delivery is free at the threshold', () {
    expect(Pricing.deliveryCharge(1999), 150);
    expect(Pricing.deliveryCharge(2000), 0);
    expect(Pricing.deliveryCharge(0), 0);
    expect(Pricing.grandTotal(1999), 2149);
  });

  test('validators reject empty and malformed input', () {
    expect(Validators.email('parent@example.com'), isNull);
    expect(Validators.email('not-an-email'), isNotNull);
    expect(Validators.phone('03001234567'), isNull);
    expect(Validators.phone('123'), isNotNull);
    expect(Validators.password('secret'), isNull);
    expect(Validators.password('123'), isNotNull);
    expect(Validators.confirmPassword('secret', 'secret'), isNull);
    expect(Validators.confirmPassword('other', 'secret'), isNotNull);
    expect(Validators.fullName('A'), isNotNull);
    expect(Validators.fullName('Ayesha Khan'), isNull);
  });
}
