import 'app_constants.dart';

/// Integer rupee pricing shared by the app and Cloud Functions.
class Pricing {
  const Pricing._();

  static int unitPrice(int price, int discount) {
    final safeDiscount = discount.clamp(0, 100);
    final raw = price * (100 - safeDiscount);
    return (raw + 50) ~/ 100;
  }

  static int lineTotal(int price, int discount, int quantity) {
    return unitPrice(price, discount) * quantity;
  }

  static int subtotal(Iterable<int> lineTotals) {
    return lineTotals.fold(0, (sum, line) => sum + line);
  }

  static int deliveryCharge(int subtotal) {
    if (subtotal <= 0 || subtotal >= AppConstants.freeDeliveryThreshold) return 0;
    return AppConstants.deliveryCharge;
  }

  static int grandTotal(int subtotal) => subtotal + deliveryCharge(subtotal);
}
