import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_profile_app/models/cart_item.dart';
import 'package:skill_profile_app/providers/cart_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CartState', () {
    test('initial state is empty', () {
      final state = CartState();
      expect(state.items, isEmpty);
      expect(state.promoCode, isNull);
      expect(state.discountPercent, 0);
    });

    test('subtotal calculates correctly', () {
      final state = CartState(items: const [
        CartItem(
          id: '1',
          productId: 'p1',
          name: 'T-Shirt',
          specs: 'M',
          price: 99000,
          quantity: 2,
          img: 'https://example.com/tshirt.jpg',
        ),
        CartItem(
          id: '2',
          productId: 'p2',
          name: 'Hat',
          specs: 'One Size',
          price: 50000,
          quantity: 1,
          img: 'https://example.com/hat.jpg',
        ),
      ]);

      expect(state.subtotal, 248000);
    });

    test('shipping fee is 15 when subtotal < 250 and > 0', () {
      final state = CartState(items: const [
        CartItem(
          id: '1',
          productId: 'p1',
          name: 'Sticker',
          specs: 'Small',
          price: 50,
          quantity: 2,
          img: 'https://example.com/sticker.jpg',
        ),
      ]);

      expect(state.shippingFee, 15.0);
    });

    test('shipping fee is 0 when subtotal >= 250', () {
      final state = CartState(items: const [
        CartItem(
          id: '1',
          productId: 'p1',
          name: 'T-Shirt',
          specs: 'M',
          price: 99000,
          quantity: 1,
          img: 'https://example.com/tshirt.jpg',
        ),
      ]);

      expect(state.shippingFee, 0.0);
    });

    test('shipping fee is 0 when cart is empty', () {
      final state = CartState();
      expect(state.shippingFee, 0.0);
    });

    test('discount amount calculates correctly', () {
      final state = CartState(
        items: const [
          CartItem(
            id: '1',
            productId: 'p1',
            name: 'T-Shirt',
            specs: 'M',
            price: 100000,
            quantity: 1,
            img: 'https://example.com/tshirt.jpg',
          ),
        ],
        discountPercent: 20,
      );

      expect(state.discountAmount, 20000);
    });

    test('total calculates correctly with all components', () {
      final state = CartState(
        items: const [
          CartItem(
            id: '1',
            productId: 'p1',
            name: 'T-Shirt',
            specs: 'M',
            price: 99000,
            quantity: 1,
            img: 'https://example.com/tshirt.jpg',
          ),
        ],
        discountPercent: 10,
      );

      // subtotal: 99000, shipping: 0 (subtotal >= 250), discount: 9900
      expect(state.total, 99000 + 0 - 9900);
    });

    test('totalItems counts all items correctly', () {
      final state = CartState(items: const [
        CartItem(
          id: '1',
          productId: 'p1',
          name: 'T-Shirt',
          specs: 'M',
          price: 99000,
          quantity: 2,
          img: 'https://example.com/tshirt.jpg',
        ),
        CartItem(
          id: '2',
          productId: 'p2',
          name: 'Hat',
          specs: 'One Size',
          price: 50000,
          quantity: 3,
          img: 'https://example.com/hat.jpg',
        ),
      ]);

      expect(state.totalItems, 5);
    });

    test('copyWith creates modified copy', () {
      final original = CartState(
        promoCode: 'WELCOME10',
        discountPercent: 10,
      );

      final modified = original.copyWith(promoCode: 'FOUNDER20', discountPercent: 20);

      expect(modified.promoCode, 'FOUNDER20');
      expect(modified.discountPercent, 20);
      expect(original.promoCode, 'WELCOME10');
    });
  });

  group('CartNotifier', () {
    late ProviderContainer container;
    late CartNotifier notifier;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      notifier = container.read(cartProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('adds item to empty cart', () {
      const item = CartItem(
        id: '1',
        productId: 'p1',
        name: 'T-Shirt',
        specs: 'M',
        price: 99000,
        quantity: 1,
        img: 'https://example.com/tshirt.jpg',
      );

      notifier.addItem(item);
      final state = container.read(cartProvider);

      expect(state.items.length, 1);
      expect(state.items.first.productId, 'p1');
    });

    test('increments quantity when adding duplicate item', () {
      const item = CartItem(
        id: '1',
        productId: 'p1',
        name: 'T-Shirt',
        specs: 'M',
        price: 99000,
        quantity: 1,
        img: 'https://example.com/tshirt.jpg',
      );

      notifier.addItem(item);
      notifier.addItem(item);
      final state = container.read(cartProvider);

      expect(state.items.length, 1);
      expect(state.items.first.quantity, 2);
    });

    test('adds different items separately', () {
      const item1 = CartItem(
        id: '1',
        productId: 'p1',
        name: 'T-Shirt',
        specs: 'M',
        price: 99000,
        quantity: 1,
        img: 'https://example.com/tshirt.jpg',
      );
      const item2 = CartItem(
        id: '2',
        productId: 'p2',
        name: 'Hat',
        specs: 'One Size',
        price: 50000,
        quantity: 1,
        img: 'https://example.com/hat.jpg',
      );

      notifier.addItem(item1);
      notifier.addItem(item2);
      final state = container.read(cartProvider);

      expect(state.items.length, 2);
    });

    test('removes item from cart', () {
      const item = CartItem(
        id: '1',
        productId: 'p1',
        name: 'T-Shirt',
        specs: 'M',
        price: 99000,
        quantity: 1,
        img: 'https://example.com/tshirt.jpg',
      );

      notifier.addItem(item);
      notifier.removeItem('p1');
      final state = container.read(cartProvider);

      expect(state.items, isEmpty);
    });

    test('removes only the specified item', () {
      const item1 = CartItem(
        id: '1',
        productId: 'p1',
        name: 'T-Shirt',
        specs: 'M',
        price: 99000,
        quantity: 1,
        img: 'https://example.com/tshirt.jpg',
      );
      const item2 = CartItem(
        id: '2',
        productId: 'p2',
        name: 'Hat',
        specs: 'One Size',
        price: 50000,
        quantity: 1,
        img: 'https://example.com/hat.jpg',
      );

      notifier.addItem(item1);
      notifier.addItem(item2);
      notifier.removeItem('p1');
      final state = container.read(cartProvider);

      expect(state.items.length, 1);
      expect(state.items.first.productId, 'p2');
    });

    test('updateQuantity increases quantity', () {
      const item = CartItem(
        id: '1',
        productId: 'p1',
        name: 'T-Shirt',
        specs: 'M',
        price: 99000,
        quantity: 1,
        img: 'https://example.com/tshirt.jpg',
      );

      notifier.addItem(item);
      notifier.updateQuantity('p1', 1);
      final state = container.read(cartProvider);

      expect(state.items.first.quantity, 2);
    });

    test('updateQuantity decreases quantity', () {
      const item = CartItem(
        id: '1',
        productId: 'p1',
        name: 'T-Shirt',
        specs: 'M',
        price: 99000,
        quantity: 2,
        img: 'https://example.com/tshirt.jpg',
      );

      notifier.addItem(item);
      notifier.updateQuantity('p1', -1);
      final state = container.read(cartProvider);

      expect(state.items.first.quantity, 1);
    });

    test('updateQuantity does not go below 1', () {
      const item = CartItem(
        id: '1',
        productId: 'p1',
        name: 'T-Shirt',
        specs: 'M',
        price: 99000,
        quantity: 1,
        img: 'https://example.com/tshirt.jpg',
      );

      notifier.addItem(item);
      notifier.updateQuantity('p1', -1);
      final state = container.read(cartProvider);

      expect(state.items.first.quantity, 1);
    });

    test('applyPromo with FOUNDER20 gives 20% discount', () {
      notifier.applyPromo('FOUNDER20');
      final state = container.read(cartProvider);

      expect(state.promoCode, 'FOUNDER20');
      expect(state.discountPercent, 20);
    });

    test('applyPromo with WELCOME10 gives 10% discount', () {
      notifier.applyPromo('WELCOME10');
      final state = container.read(cartProvider);

      expect(state.promoCode, 'WELCOME10');
      expect(state.discountPercent, 10);
    });

    test('applyPromo is case insensitive', () {
      notifier.applyPromo('founder20');
      final state = container.read(cartProvider);

      expect(state.promoCode, 'FOUNDER20');
      expect(state.discountPercent, 20);
    });

    test('applyPromo with invalid code does nothing', () {
      notifier.applyPromo('INVALID');
      final state = container.read(cartProvider);

      expect(state.promoCode, isNull);
      expect(state.discountPercent, 0);
    });

    test('clearCart resets to empty state', () {
      const item = CartItem(
        id: '1',
        productId: 'p1',
        name: 'T-Shirt',
        specs: 'M',
        price: 99000,
        quantity: 1,
        img: 'https://example.com/tshirt.jpg',
      );

      notifier.addItem(item);
      notifier.applyPromo('FOUNDER20');
      notifier.clearCart();
      final state = container.read(cartProvider);

      expect(state.items, isEmpty);
      expect(state.promoCode, isNull);
      expect(state.discountPercent, 0);
    });
  });
}
