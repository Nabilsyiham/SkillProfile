# Riverpod + Freezed Refactor Implementation Plan

> **For agentic workers:** Use subagent-driven-development or executing-plans to implement this plan task-by-task.

**Goal:** Refactor seluruh state management ke Riverpod dan buat data models dengan Freezed

**Architecture:** Pisahkan state dari UI, buat data models immutable, gunakan providers untuk cart/auth/products

**Tech Stack:** flutter_riverpod, freezed_annotation, json_serializable, go_router, cached_network_image

---

## File Structure yang akan dibuat/diubah:

```
lib/
  models/
    product.dart           # Model produk
    cart_item.dart         # Item keranjang
    user.dart              # Model user
  providers/
    products_provider.dart # Provider produk
    cart_provider.dart     # Provider keranjang
    auth_provider.dart     # Provider autentikasi
  services/
    product_service.dart   # Service produk
    cart_service.dart      # Service keranjang
  screens/                 # Update semua screen
  router.dart              # Go router setup
```

---

## Task 1: Tambah Dependencies

**Files:** pubspec.yaml

- [ ] Buka pubspec.yaml, tambahkan dependencies:

```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  go_router: ^13.0.0
  cached_network_image: ^3.3.1
  get_it: ^7.6.7

dev_dependencies:
  freezed: ^2.4.7
  json_serializable: ^6.7.1
  build_runner: ^2.4.8
  riverpod_generator: ^2.3.9
```

- [ ] Jalankan `flutter pub get`
- [ ] Commit

---

## Task 2: Buat Product Model

**Files:** lib/models/product.dart

- [ ] Buat file `lib/models/product.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String category,
    required double price,
    required String imageUrl,
    String? description,
    List<String>? colors,
    List<String>? sizes,
    bool? isNew,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}
```

- [ ] Jalankan `dart run build_runner build --delete-conflicting-outputs`
- [ ] Verifikasi file `product.freezed.dart` dan `product.g.dart` terbuat
- [ ] Commit

---

## Task 3: Buat CartItem Model

**Files:** lib/models/cart_item.dart

- [ ] Buat file `lib/models/cart_item.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required String id,
    required String productId,
    required String name,
    required String specs,
    required double price,
    required int quantity,
    required String imageUrl,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
}
```

- [ ] Jalankan `dart run build_runner build --delete-conflicting-outputs`
- [ ] Commit

---

## Task 4: Buat User Model

**Files:** lib/models/user.dart

- [ ] Buat file `lib/models/user.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? firstName,
    String? lastName,
    String? avatarUrl,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

- [ ] Jalankan `dart run build_runner build --delete-conflicting-outputs`
- [ ] Commit

---

## Task 5: Buat Cart Provider

**Files:** lib/providers/cart_provider.dart

- [ ] Buat file `lib/providers/cart_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';

class CartState {
  final List<CartItem> items;
  final String? promoCode;
  final double discountPercent;

  CartState({
    this.items = const [],
    this.promoCode,
    this.discountPercent = 0,
  });

  double get subtotal {
    double total = 0;
    for (var item in items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  double get shippingFee => subtotal < 250 && subtotal > 0 ? 15.0 : 0.0;
  double get discountAmount => subtotal * (discountPercent / 100);
  double get total => subtotal + shippingFee - discountAmount;
  int get totalItems {
    int count = 0;
    for (var item in items) {
      count += item.quantity;
    }
    return count;
  }

  CartState copyWith({
    List<CartItem>? items,
    String? promoCode,
    double? discountPercent,
  }) {
    return CartState(
      items: items ?? this.items,
      promoCode: promoCode ?? this.promoCode,
      discountPercent: discountPercent ?? this.discountPercent,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addItem(CartItem item) {
    final existingIndex = state.items.indexWhere((i) => i.productId == item.productId);
    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      final updatedItem = existing.copyWith(quantity: existing.quantity + 1);
      final updatedItems = [...state.items];
      updatedItems[existingIndex] = updatedItem;
      state = state.copyWith(items: updatedItems);
    } else {
      state = state.copyWith(items: [...state.items, item]);
    }
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.productId != productId).toList(),
    );
  }

  void updateQuantity(String productId, int delta) {
    final index = state.items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      final existing = state.items[index];
      final newQty = existing.quantity + delta;
      if (newQty >= 1) {
        final updatedItem = existing.copyWith(quantity: newQty);
        final updatedItems = [...state.items];
        updatedItems[index] = updatedItem;
        state = state.copyWith(items: updatedItems);
      }
    }
  }

  void applyPromo(String code) {
    final upperCode = code.toUpperCase();
    if (upperCode == 'FOUNDER20') {
      state = state.copyWith(promoCode: upperCode, discountPercent: 20);
    } else if (upperCode == 'WELCOME10') {
      state = state.copyWith(promoCode: upperCode, discountPercent: 10);
    }
  }

  void clearCart() {
    state = CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
```

- [ ] Commit

---

## Task 6: Buat Products Provider

**Files:** lib/providers/products_provider.dart

- [ ] Buat file `lib/providers/products_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

final productsProvider = Provider<List<Product>>((ref) {
  return [
    Product(
      id: '1',
      name: 'Cashmere Ribbed Turtleneck',
      category: 'Knitwear',
      price: 285.00,
      imageUrl: 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=600&q=80&fit=crop',
      isNew: true,
    ),
    Product(
      id: '2',
      name: 'Wide-Leg Silk Trousers',
      category: 'Bottoms',
      price: 195.00,
      imageUrl: 'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=600&q=80&fit=crop',
    ),
    Product(
      id: '3',
      name: 'Italian Leather Tote',
      category: 'Bags',
      price: 420.00,
      imageUrl: 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600&q=80&fit=crop',
    ),
    Product(
      id: '4',
      name: 'Chelsea Ankle Boot',
      category: 'Shoes',
      price: 280.00,
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=80&fit=crop',
    ),
    Product(
      id: '5',
      name: 'Structured Leather Shoulder Bag',
      category: 'Bags',
      price: 320.00,
      imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600&q=80&fit=crop',
    ),
    Product(
      id: '6',
      name: 'Milan Leather Ankle Boot',
      category: 'Shoes',
      price: 390.00,
      imageUrl: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600&q=80&fit=crop',
    ),
  ];
});
```

- [ ] Commit

---

## Task 7: Update ProductCard Widget

**Files:** lib/screens/widgets/product_card.dart

- [ ] Buat folder `lib/screens/widgets/`
- [ ] Buat file `lib/screens/widgets/product_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_profile_app/models/product.dart';
import 'package:skill_profile_app/providers/cart_provider.dart';
import 'package:skill_profile_app/theme/app_theme.dart';
import 'package:skill_profile_app/models/cart_item.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.canvas,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.linen),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: AppTheme.surface,
                      image: DecorationImage(
                        image: NetworkImage(product.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(cartProvider.notifier).addItem(
                          CartItem(
                            id: DateTime.now().toString(),
                            productId: product.id,
                            name: product.name,
                            specs: product.category,
                            price: product.price,
                            quantity: 1,
                            imageUrl: product.imageUrl,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product.name} added to cart')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.canvas.withOpacity(0.8),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.linen),
                        ),
                        child: const Icon(Icons.add_shopping_cart, size: 14, color: AppTheme.charcoal),
                      ),
                    ),
                  ),
                  if (product.isNew == true)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.sage,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'NEW',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.canvas,
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.category.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.pebble,
                fontSize: 9,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] Commit

---

## Task 8: Update ShopScreen

**Files:** lib/screens/shop_screen.dart

- [ ] Update import dan gunakan ProductCard:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_profile_app/providers/products_provider.dart';
import 'package:skill_profile_app/screens/widgets/product_card.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shop',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return ProductCard(product: products[index]);
                },
                childCount: products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] Commit

---

## Task 9: Update HomeScreen

**Files:** lib/screens/home_screen.dart

- [ ] Update `_buildFeaturedEssentials` untuk gunakan provider:

```dart
Widget _buildFeaturedEssentials(BuildContext context, WidgetRef ref) {
  final products = ref.watch(productsProvider);

  return Container(
    color: AppTheme.surface,
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
    child: Column(
      children: [
        // ... heading sama
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.55,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductCard(product: products[index]);
          },
        ),
      ],
    ),
  );
}
```

- [ ] Ubah HomeScreen dari `StatelessWidget` ke `ConsumerWidget`
- [ ] Commit

---

## Task 10: Update CartScreen

**Files:** lib/screens/cart_screen.dart

- [ ] Ubah CartScreen ke ConsumerWidget, gunakan cartProvider
- [ ] Hapus semua hardcoded cartItems, gunakan `ref.watch(cartProvider)`
- [ ] Update semua method (_updateQty, _removeItem, _applyPromo) untuk pakai provider
- [ ] Commit

---

## Task 11: Update main.dart untuk ProviderScope

**Files:** lib/main.dart

- [ ] Bungkus MaterialApp dengan ProviderScope:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_profile_app/theme/app_theme.dart';
import 'package:skill_profile_app/screens/main_screen.dart';

void main() {
  runApp(const ProviderScope(child: FeaturesAndFoundApp()));
}

class FeaturesAndFoundApp extends StatelessWidget {
  const FeaturesAndFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Features & Found',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}
```

- [ ] Commit

---

## Task 12: Jalankan Build Runner

- [ ] Jalankan: `dart run build_runner build --delete-conflicting-outputs`
- [ ] Periksa tidak ada error
- [ ] Jalankan: `flutter analyze`
- [ ] Fix semua warnings/errors
- [ ] Commit

---

## Task 13: Testing

- [ ] Jalankan `flutter test`
- [ ] Pastikan tidak ada regressions
- [ ] Test manual: tambah item ke cart, update qty, apply promo
- [ ] Commit

---

## Ringkasan Perubahan

| File | Status |
|------|--------|
| pubspec.yaml | Diubah |
| lib/main.dart | Diubah (ProviderScope) |
| lib/models/product.dart | Baru |
| lib/models/cart_item.dart | Baru |
| lib/models/user.dart | Baru |
| lib/providers/cart_provider.dart | Baru |
| lib/providers/products_provider.dart | Baru |
| lib/screens/widgets/product_card.dart | Baru |
| lib/screens/shop_screen.dart | Diubah |
| lib/screens/home_screen.dart | Diubah |
| lib/screens/cart_screen.dart | Diubah |
