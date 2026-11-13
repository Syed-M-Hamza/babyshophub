# BabyShopHub

BabyShopHub is a pastel baby-products shopping app for Android, built with Flutter, Provider, and Firebase. Customers browse a live Firestore catalog, keep a cart and wishlist, check out with cash on delivery or a dummy online payment, and follow order status. Administrators manage the catalog, orders, customers, reviews, and support requests.

Firebase project: `babyshophub-430f1`.

## What was verified

These commands were run in this workspace:

- `flutter pub get`
- `flutter analyze` — no issues
- `flutter test` — 5 tests passed (pricing, delivery, validators, money format, a small widget smoke test)

`flutter run` was not started here, so the phone UI has not been clicked through on a device in this session. After you deploy the security rules, run the app on an Android emulator or phone and follow the demonstration checklist below.

## Run the app

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Use an Android device or emulator. The project already contains `android/app/google-services.json` and `lib/firebase_options.dart`.

## Grant an administrator

The app does not contain an admin password, and customers cannot edit their own `role`.

1. Register a normal account in the app.
2. Copy that account's uid from Firebase Authentication, or from the admin customer list after another admin exists.
3. In Firestore, create a document at `admins/{that uid}`. Any field is fine, for example `active: true`.
4. Clients cannot write this collection. Only the Firebase console or the Admin SDK can create it.
5. Reopen the app. That user lands on the admin dashboard.

On the dashboard, tap **Seed sample catalog** once. That writes the ten categories, twenty products, and the single store profile. Product photos are remote sample images, so the phone needs internet.

## Deploy security rules

```bash
npm install -g firebase-tools
firebase login
firebase deploy --only firestore:rules,storage
```

Do this before demonstrating. Until the rules in `firestore.rules` and `storage.rules` are published, the live database is still using whatever rules are currently in the Firebase console.

Cloud Functions are included for authoritative checkout, but they need the Blaze plan:

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

If `placeOrder` or `cancelOrder` is not deployed, the app places and cancels orders with a Firestore transaction instead. That transaction reads the current product price and stock from Firestore. It does not trust the price shown in an old cart widget. A modified client could still change the `stock` number directly, because Spark projects cannot run Cloud Functions. After you deploy the functions, remove the customer stock-update branch in `firestore.rules` so only the Admin SDK can change stock.

## Collections

| Collection | Purpose |
| --- | --- |
| `users/{uid}` | Profile. `role` is always `customer` when the app creates it. |
| `users/{uid}/addresses/{id}` | Delivery addresses. |
| `admins/{uid}` | Trusted admin allow-list. Console only. |
| `categories`, `products` | Catalog. Customers can update only stock or rating counters. |
| `carts/{uid_productId}` | Cart lines. |
| `wishlists/{uid_productId}` | Favourites. |
| `orders/{id}` | Order with a product snapshot, totals, payment, and status. |
| `reviews/{uid_productId}` | One review per customer per product. |
| `support_tickets` | Support, feedback, and problem reports. |
| `notifications` | In-app alerts. |
| `checkout_locks/{uid}` | Short lock that blocks a second checkout for 20 seconds. |
| `sellers/babyshophub` | Single-store profile. |
| `seller_feedback/{uid}` | One store rating per customer. |

Money is stored in whole rupees. Delivery is Rs 150, and free from Rs 2,000.

Order statuses: placed, confirmed, processing, packed, shipped, out for delivery, delivered, cancelled. Customers can cancel only while the order is placed or confirmed. The tracking screen is a status timeline, not a map.

Payments are cash on delivery, or a dummy online payment that marks the order paid without a card form.

## Demonstration checklist

1. Register, log out, log in with a wrong password, then log in correctly.
2. Use Forgot password and confirm the reset email in Firebase Authentication.
3. As admin, seed the catalog and confirm the home carousels fill in.
4. Search, filter by category, price, and rating, and open a product.
5. Add to cart, change quantity, remove a line, and add a favourite.
6. Save two addresses, mark one as the default, and check out with cash on delivery.
7. Place a second order with dummy online payment and open the success screen.
8. Cancel a newly placed order and confirm the stock returns.
9. Submit a review and a support request.
10. As admin, edit a product, change an order to shipped, reply to the ticket, and deactivate a customer.
11. Confirm the deactivated customer sees the inactive screen and can log out.

## Project layout

`lib/main.dart` starts Firebase and chooses splash, onboarding, auth, the customer shell, or the admin shell. Models, services, providers, screens, widgets, theme, and utils are split under `lib/`. Rules live in `firestore.rules` and `storage.rules`. Order functions live in `functions/index.js`. The academic write-up is in `docs/PROJECT_REPORT.md`.
"# babyshophub" 
"# babyshophub" 
"# babyshophub" 
