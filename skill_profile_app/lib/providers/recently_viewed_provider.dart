import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

class RecentlyViewedNotifier extends StateNotifier<List<Product>> {
  RecentlyViewedNotifier() : super([]);

  static const int _maxItems = 10;

  void addProduct(Product product) {
    state = state.where((p) => p.id != product.id).toList();
    state = [product, ...state];
    if (state.length > _maxItems) {
      state = state.sublist(0, _maxItems);
    }
  }
}

final recentlyViewedProvider =
    StateNotifierProvider<RecentlyViewedNotifier, List<Product>>((ref) {
  return RecentlyViewedNotifier();
});
