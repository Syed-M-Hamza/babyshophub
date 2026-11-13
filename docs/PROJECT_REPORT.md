# BabyShopHub project report

## 1. Introduction

BabyShopHub is an Android shopping application for parents and caregivers. It sells baby clothing, diapers, food, toys, skincare, feeding items, bath products, accessories, bedding, and health products. The app is an Aptech eProject built with Flutter and Firebase.

## 2. Objectives

- Let a customer create an account, browse a live catalog, and buy products.
- Keep the cart, wishlist, addresses, orders, reviews, and support requests in Cloud Firestore.
- Give administrators a separate dashboard that customers cannot open by editing their profile.
- Keep the interface on one soft pastel theme from splash through checkout and admin tools.
- Record prices and stock on the order so later catalog edits do not rewrite history.

## 3. Problem statement

Parents often buy baby essentials from several shops and have little visibility after the order is placed. A single boutique app can collect the catalog, the cart, delivery details, and order status in one place. The project also has to keep customer records private and stop a customer from making themselves an administrator.

## 4. Functional requirements

- Splash, three onboarding pages, registration, login, logout, and password reset.
- Home with a greeting, search entry, banner, categories, and product carousels.
- Search by name, brand, and category, plus price, rating, and sort filters.
- Product details, reviews, cart, wishlist, checkout, and order tracking.
- Profile, addresses, store feedback, and support tickets.
- Admin statistics, product and category management, customer active status, order status, review deletion, and ticket replies.
- In-app notifications when an order is placed, cancelled, or updated by an admin.

## 5. Non-functional requirements

- Material 3, null safety, and Provider for state.
- Pastel palette: white, cream, peach, pink, blue, mint, navy, and soft orange.
- Firestore and Storage rules that are not public read/write.
- Prices for a new order are read from the product document at checkout time.
- Dummy payment never asks for a card number.
- Order tracking shows status only. It does not pretend to be GPS.

## 6. Software and hardware

- Flutter stable (this workspace used Flutter 3.47.7 and Dart 3.13.5).
- Android phone or emulator, minimum SDK 23.
- Firebase project `babyshophub-430f1` with Authentication, Firestore, Storage, and Cloud Messaging enabled.
- Optional Blaze plan if Cloud Functions are deployed.
- A computer with the Flutter SDK, Android SDK, and internet.

## 7. Technology stack

Flutter, Dart, Firebase Authentication, Cloud Firestore, Firebase Storage, Firebase Cloud Messaging, Cloud Functions, Provider, Material 3, and the packages listed in `pubspec.yaml`.

## 8. Architecture

`AuthGate` chooses the screen from Firebase auth state, the onboarding flag in SharedPreferences, the user profile, and the `admins/{uid}` document. Customer screens sit in a shell with Home, Explore, Favourite, and Profile. Admin screens use a separate shell. Services talk to Firebase. Providers hold the live lists for products, the cart, the wishlist, and the signed-in customer's orders. Checkout calls the `placeOrder` function when it exists, and otherwise runs a Firestore transaction that re-reads each product.

## 9. Database structure

See the collection table in `README.md`. An order stores `products` as a list of snapshots: name, image, original price, discount, unit price, quantity, and line total. User passwords are never written to Firestore.

## 10. Screenshots

Screenshots were not captured in this development session because the app was not launched on a device here. For the submission, run `flutter run` and capture:

1. Splash and the three onboarding pages.
2. Register and login.
3. Home, a category, and product details.
4. Cart, checkout, and order success.
5. Order tracking.
6. Profile, addresses, wishlist, and support.
7. Admin dashboard, product form, and an order status update.

## 11. User manual

Register with your name, email, phone, and a password of at least 6 characters. After login, browse Home or Explore, open a product, and use Add to cart or the heart icon. Open the cart, adjust quantities, and check out. Add an address if you do not have one. Choose cash on delivery or the demo online payment. Track the order from Profile, My orders. Cancel it only while it is placed or confirmed. Use Support for a question or problem, and Our store to leave one shop rating.

## 12. Developer notes

- Admin access is the existence of `admins/{uid}`. The profile `role` field cannot be changed by the client.
- `SeedService` refuses to seed again once any product exists.
- Cart document ids are `{uid}_{productId}`, so a product appears once.
- Review document ids are `{uid}_{productId}`.
- Delivery and rounding live in `lib/utils/pricing.dart` and are repeated in `functions/index.js`.
- FCM registration stores the installation id on the user document for a later server send. The bell list itself is the Firestore `notifications` collection.

## 13. Installation

```bash
flutter pub get
flutter run
```

The Android application id is `com.example.babyshophub`.

## 14. Firebase setup

Authentication: enable Email/Password. Firestore and Storage: deploy `firestore.rules` and `storage.rules`. Create the first `admins/{uid}` document in the console. Cloud Messaging is configured through the existing `google-services.json`. Functions are optional and documented in the README.

## 15. Testing report

Automated checks in this session:

- `flutter analyze`: no issues.
- `flutter test`: 5 tests passed, covering rupee rounding, the free-delivery threshold, email/phone/password validation, and the money formatter.

Device checks still to perform are listed in the README demonstration checklist. Those clicks were not run here, so this report does not claim a full manual pass.

## 16. Future enhancements

- Deploy `placeOrder` and then delete the client stock-update exception in the rules.
- Add Firebase App Check.
- Replace sample image URLs with photographs uploaded by the shop.
- Add a returns flow and saved payment references that still do not collect raw card data.

## 17. Source code

The Flutter source is under `lib/`. Backend rules are `firestore.rules` and `storage.rules`. Callable order logic is `functions/index.js`.

## 18. Video checklist

Record in this order: splash, onboarding, register, login, home, search, product, cart, checkout, order timeline, profile, then switch to the admin account and show a product edit, an order status change, and a support reply. End by showing that a normal user document does not contain a password and that the `admins` document was created in the console.
