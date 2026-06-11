import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_service.dart';

final apiWishlistProvider = FutureProvider<List<dynamic>>((ref) async {
  final result = await ApiService.get('/wishlist');
  return result['data'] ?? result ?? [];
});

final wishlistItemsProvider = FutureProvider<List<Product>>((ref) async {
  final wishlistData = await ref.watch(apiWishlistProvider.future);
  return wishlistData.map((item) {
    final productData = item['product'] ?? item;
    return Product.fromJson(productData as Map<String, dynamic>);
  }).toList();
});

class WishlistNotifier extends StateNotifier<List<Product>> {
  final Ref ref;

  WishlistNotifier(this.ref) : super([]) {
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    try {
      final items = await ref.read(wishlistItemsProvider.future);
      state = items;
    } catch (e) {
      state = [];
    }
  }

  Future<void> addItem(Product product) async {
    if (!state.any((p) => p.id == product.id)) {
      await ApiService.post('/wishlist', body: {'product_id': product.id});
      state = [...state, product];
    }
  }

  Future<void> removeItem(String productId) async {
    await ApiService.delete('/wishlist/$productId');
    state = state.where((p) => p.id != productId).toList();
  }

  Future<void> toggleItem(Product product) async {
    if (isInWishlist(product.id)) {
      await removeItem(product.id);
    } else {
      await addItem(product);
    }
  }

  bool isInWishlist(String productId) {
    return state.any((p) => p.id == productId);
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<Product>>((ref) {
  return WishlistNotifier(ref);
});
