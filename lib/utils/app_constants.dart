class AppConstants {
  const AppConstants._();

  static const String appName = 'BabyShopHub';
  static const String onboardingKey = 'onboarding_complete';
  static const String storeSellerId = 'babyshophub';
  static const int freeDeliveryThreshold = 2000;
  static const int deliveryCharge = 150;
  static const int maxCartQuantity = 20;
  static const int maxOrderLines = 20;

  static const List<String> orderStatuses = [
    'placed',
    'confirmed',
    'processing',
    'packed',
    'shipped',
    'out_for_delivery',
    'delivered',
    'cancelled',
  ];

  static const List<String> cancellableStatuses = ['placed', 'confirmed'];

  static const List<String> supportCategories = [
    'Order',
    'Payment',
    'Delivery',
    'Product',
    'Account',
    'Other',
  ];
}
