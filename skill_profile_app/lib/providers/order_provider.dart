import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_provider.freezed.dart';

enum OrderStatus { pending, processing, shipped, delivered }

@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required List<OrderItem> items,
    required double total,
    required DateTime orderDate,
    required OrderStatus status,
    required String shippingAddress,
  }) = _Order;
}

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String name,
    required int quantity,
    required double price,
    required String img,
  }) = _OrderItem;
}

class OrderNotifier extends StateNotifier<List<Order>> {
  OrderNotifier() : super(_sampleOrders);

  void addOrder(Order order) {
    state = [order, ...state];
  }
}

final List<Order> _sampleOrders = [
  Order(
    id: 'ORD-001',
    items: [
      const OrderItem(name: 'Cashmere Ribbed Cardigan', quantity: 1, price: 285.00, img: 'https://images.unsplash.com/photo-1670080589800-6416c8ce8a14?w=500&auto=format&fit=crop&q=60'),
      const OrderItem(name: 'Leather Backpack', quantity: 1, price: 2200.00, img: 'https://images.unsplash.com/photo-1622560480654-d96214fdc887?w=500&auto=format&fit=crop&q=60'),
    ],
    total: 2485.00,
    orderDate: DateTime(2026, 5, 15),
    status: OrderStatus.delivered,
    shippingAddress: '123 Fashion Street, Jakarta',
  ),
  Order(
    id: 'ORD-002',
    items: [
      const OrderItem(name: 'Chelsea Ankle Boots', quantity: 1, price: 2280.00, img: 'https://images.unsplash.com/photo-1605733513549-de9b150bd70d?w=500&auto=format&fit=crop&q=60'),
    ],
    total: 2280.00,
    orderDate: DateTime(2026, 6, 1),
    status: OrderStatus.shipped,
    shippingAddress: '456 Style Avenue, Bandung',
  ),
  Order(
    id: 'ORD-003',
    items: [
      const OrderItem(name: 'Denim Long Trousers', quantity: 2, price: 395.00, img: 'https://images.unsplash.com/photo-1718252540511-e958742e4165?w=500&auto=format&fit=crop&q=60'),
    ],
    total: 790.00,
    orderDate: DateTime(2026, 6, 8),
    status: OrderStatus.processing,
    shippingAddress: '789 Trend Road, Surabaya',
  ),
];

final orderProvider = StateNotifierProvider<OrderNotifier, List<Order>>((ref) {
  return OrderNotifier();
});
