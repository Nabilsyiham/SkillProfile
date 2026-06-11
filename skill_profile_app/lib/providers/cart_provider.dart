import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/cart_item.dart';

class CartItemData {
  final int id;
  final CartItem item;

  CartItemData({required this.id, required this.item});
}

class CartState {
  final List<CartItemData> items;

  CartState({this.items = const []});

  double get subtotal {
    double total = 0;
    for (var data in items) {
      total += data.item.price * data.item.quantity;
    }
    return total;
  }

  double get shippingFee {
    return subtotal < 250000 ? 15000 : 0;
  }

  double get total => subtotal + shippingFee;

  int get totalItems {
    int count = 0;
    for (var data in items) {
      count += data.item.quantity;
    }
    return count;
  }

  CartState copyWith({List<CartItemData>? items}) {
    return CartState(items: items ?? this.items);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState()) {
    loadCart();
  }

  Future<void> loadCart() async {
    try {
      final result = await ApiService.get('/cart');
      final cartList = result['cart'] ?? [];
      final items = (cartList as List).map((e) {
        final product = e['product'] ?? {};
        return CartItemData(
          id: e['id'],
          item: CartItem(
            id: e['id'].toString(),
            productId: (e['product_id'] ?? '').toString(),
            name: product['name'] ?? '',
            specs: '${e['color'] ?? ''} / ${e['size'] ?? ''}',
            price: double.tryParse(product['price']?.toString() ?? '0') ?? 0,
            quantity: e['quantity'] ?? 1,
            img: product['img'] ?? '',
          ),
        );
      }).toList();
      state = state.copyWith(items: items);
    } catch (e) {
      print('loadCart error: $e');
    }
  }

  Future<void> addItem(CartItem item) async {
    final specsParts = item.specs.split(' / ');
    String color = '';
    String size = '';
    if (specsParts.length >= 3) {
      size = specsParts[1].trim();
      color = specsParts[2].trim();
    } else if (specsParts.length == 2) {
      color = specsParts[0].trim();
      size = specsParts[1].trim();
    }

    try {
      final result = await ApiService.post('/cart', body: {
        'product_id': int.parse(item.productId),
        'color': color,
        'size': size,
        'quantity': 1,
      });
      final cartItem = result['cart'];
      if (cartItem != null) {
        final product = cartItem['product'] ?? {};
        state = state.copyWith(items: [
          ...state.items,
          CartItemData(
            id: cartItem['id'],
            item: CartItem(
              id: cartItem['id'].toString(),
              productId: (cartItem['product_id'] ?? '').toString(),
              name: product['name'] ?? '',
              specs: '${cartItem['color'] ?? ''} / ${cartItem['size'] ?? ''}',
              price: double.tryParse(product['price']?.toString() ?? '0') ?? 0,
              quantity: cartItem['quantity'] ?? 1,
              img: product['img'] ?? '',
            ),
          ),
        ]);
      }
    } catch (e) {
      print('addItem error: $e');
    }
  }

  Future<void> removeItem(String productId) async {
    final itemData = state.items.firstWhere(
      (data) => data.item.productId == productId,
      orElse: () => CartItemData(id: -1, item: CartItem(id: '', productId: '', name: '', specs: '', price: 0, quantity: 0, img: '')),
    );
    if (itemData.id == -1) return;

    try {
      await ApiService.delete('/cart/${itemData.id}');
      state = state.copyWith(
        items: state.items.where((data) => data.item.productId != productId).toList(),
      );
    } catch (e) {
      print('removeItem error: $e');
    }
  }

  Future<void> updateQuantity(String productId, int delta) async {
    final index = state.items.indexWhere((data) => data.item.productId == productId);
    if (index < 0) return;

    final itemData = state.items[index];
    final newQty = itemData.item.quantity + delta;
    if (newQty < 1) return;

    try {
      await ApiService.put('/cart/${itemData.id}', body: {'quantity': newQty});
      final updatedItems = [...state.items];
      updatedItems[index] = CartItemData(
        id: itemData.id,
        item: itemData.item.copyWith(quantity: newQty),
      );
      state = state.copyWith(items: updatedItems);
    } catch (e) {
      print('updateQuantity error: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await ApiService.delete('/cart');
      state = CartState();
    } catch (e) {
      print('clearCart error: $e');
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
