# Cart & Wishlist Persistence Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Persist cart and wishlist data across app restarts using SharedPreferences.

**Architecture:** Add `shared_preferences` dependency, then update `CartNotifier` and `WishlistNotifier` to load state from and save state to SharedPreferences as JSON strings on every mutation.

**Tech Stack:** Flutter, shared_preferences, json_serializable (already in use)

---

## File Structure

- `pubspec.yaml` — add shared_preferences dependency
- `lib/providers/cart_provider.dart` — add persistence logic to CartNotifier
- `lib/providers/wishlist_provider.dart` — add persistence logic to WishlistNotifier

---

### Task 1: Add shared_preferences dependency

**Files:**
- Modify: `pubspec.yaml:43` (after `get_it` line)

- [ ] **Step 1: Add dependency**

Add `shared_preferences: ^2.2.0` after the `get_it` line in `pubspec.yaml`.

- [ ] **Step 2: Run flutter pub get**

Run: `flutter pub get`

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "feat: add shared_preferences dependency"
```

---

### Task 2: Update CartNotifier with persistence

**Files:**
- Modify: `lib/providers/cart_provider.dart`

- [ ] **Step 1: Add imports and constants**

Add at top of file:
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
```

- [ ] **Step 2: Add _storageKey constant**

Add before the CartState class:
```dart
const _cartKey = 'cart_data';
const _cartPromoKey = 'cart_promo_code';
const _cartDiscountKey = 'cart_discount_percent';
```

- [ ] **Step 3: Update CartNotifier constructor to load from SharedPreferences**

Change `CartNotifier` to load persisted state:

```dart
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState()) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    final promoCode = prefs.getString(_cartPromoKey);
    final discountPercent = prefs.getDouble(_cartDiscountKey) ?? 0;

    if (cartJson != null) {
      final List<dynamic> decoded = jsonDecode(cartJson);
      final items = decoded.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList();
      state = state.copyWith(items: items, promoCode: promoCode, discountPercent: discountPercent);
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(state.items.map((e) => e.toJson()).toList());
    await prefs.setString(_cartKey, cartJson);
    await prefs.setString(_cartPromoKey, state.promoCode ?? '');
    await prefs.setDouble(_cartDiscountKey, state.discountPercent);
  }
```

- [ ] **Step 4: Update addItem to call _saveCart**

Update `addItem` method to call `_saveCart()` after state mutation:

```dart
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
    _saveCart();
  }
```

- [ ] **Step 5: Update removeItem to call _saveCart**

```dart
  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.productId != productId).toList(),
    );
    _saveCart();
  }
```

- [ ] **Step 6: Update updateQuantity to call _saveCart**

```dart
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
    _saveCart();
  }
```

- [ ] **Step 7: Update applyPromo to call _saveCart**

```dart
  void applyPromo(String code) {
    final upperCode = code.toUpperCase();
    if (upperCode == 'FOUNDER20') {
      state = state.copyWith(promoCode: upperCode, discountPercent: 20);
    } else if (upperCode == 'WELCOME10') {
      state = state.copyWith(promoCode: upperCode, discountPercent: 10);
    }
    _saveCart();
  }
```

- [ ] **Step 8: Update clearCart to call _saveCart**

```dart
  void clearCart() {
    state = CartState();
    _saveCart();
  }
```

- [ ] **Step 9: Commit**

```bash
git add lib/providers/cart_provider.dart
git commit -m "feat: add cart persistence with SharedPreferences"
```

---

### Task 3: Update WishlistNotifier with persistence

**Files:**
- Modify: `lib/providers/wishlist_provider.dart`

- [ ] **Step 1: Add imports and constant**

Add at top of file:
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
```

Add before the WishlistNotifier class:
```dart
const _wishlistKey = 'wishlist_data';
```

- [ ] **Step 2: Update WishlistNotifier to load from SharedPreferences**

Replace the full class:

```dart
class WishlistNotifier extends StateNotifier<List<Product>> {
  WishlistNotifier() : super([]) {
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistJson = prefs.getString(_wishlistKey);
    if (wishlistJson != null) {
      final List<dynamic> decoded = jsonDecode(wishlistJson);
      state = decoded.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistJson = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_wishlistKey, wishlistJson);
  }

  void addItem(Product product) {
    if (!state.any((p) => p.id == product.id)) {
      state = [...state, product];
      _saveWishlist();
    }
  }

  void removeItem(String productId) {
    state = state.where((p) => p.id != productId).toList();
    _saveWishlist();
  }

  void toggleItem(Product product) {
    if (isInWishlist(product.id)) {
      removeItem(product.id);
    } else {
      addItem(product);
    }
  }

  bool isInWishlist(String productId) {
    return state.any((p) => p.id == productId);
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/providers/wishlist_provider.dart
git commit -m "feat: add wishlist persistence with SharedPreferences"
```

---

### Task 4: Verify and final commit

- [ ] **Step 1: Run flutter analyze**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 2: Final commit (if not already committed separately)**

```bash
git add -A
git commit -m "feat: add cart and wishlist persistence"
```

---

## Report

- **Status:** DONE_WITH_CONCERNS (pending execution)
- What you implemented: Persistence layer for CartNotifier and WishlistNotifier using SharedPreferences
- Files changed: `pubspec.yaml`, `lib/providers/cart_provider.dart`, `lib/providers/wishlist_provider.dart`
- Concerns: CartState fields (promoCode, discountPercent) also persisted. Load happens asynchronously — UI may briefly show empty state before data loads. For this app's scale, this is acceptable.
