import 'package:flutter_test/flutter_test.dart';
import 'package:skill_profile_app/models/product.dart';

void main() {
  group('Product', () {
    test('creates a product with required fields', () {
      final product = Product(
        id: '1',
        name: 'Cashmere Ribbed Cardigan',
        category: 'Cardigan',
        material: 'Cashmere',
        price: 285.00,
        img: 'https://example.com/cardigan.jpg',
      );

      expect(product.id, '1');
      expect(product.name, 'Cashmere Ribbed Cardigan');
      expect(product.category, 'Cardigan');
      expect(product.material, 'Cashmere');
      expect(product.price, 285.00);
      expect(product.img, 'https://example.com/cardigan.jpg');
    });

    test('serializes to JSON correctly', () {
      final product = Product(
        id: '1',
        name: 'Cashmere Ribbed Cardigan',
        category: 'Cardigan',
        material: 'Cashmere',
        price: 285.00,
        img: 'https://example.com/cardigan.jpg',
      );

      final json = product.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Cashmere Ribbed Cardigan');
      expect(json['category'], 'Cardigan');
      expect(json['material'], 'Cashmere');
      expect(json['price'], 285.00);
      expect(json['img'], 'https://example.com/cardigan.jpg');
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'id': '1',
        'name': 'Cashmere Ribbed Cardigan',
        'category': 'Cardigan',
        'material': 'Cashmere',
        'price': 285.00,
        'img': 'https://example.com/cardigan.jpg',
      };

      final product = Product.fromJson(json);

      expect(product.id, '1');
      expect(product.name, 'Cashmere Ribbed Cardigan');
      expect(product.category, 'Cardigan');
      expect(product.material, 'Cashmere');
      expect(product.price, 285.00);
      expect(product.img, 'https://example.com/cardigan.jpg');
    });

    test('copyWith creates a modified copy', () {
      final original = Product(
        id: '1',
        name: 'Cashmere Ribbed Cardigan',
        category: 'Cardigan',
        material: 'Cashmere',
        price: 285.00,
        img: 'https://example.com/cardigan.jpg',
      );

      final modified = original.copyWith(name: 'Leather Bag', price: 1200.00);

      expect(modified.name, 'Leather Bag');
      expect(modified.price, 1200.00);
      expect(modified.id, '1');
      expect(original.name, 'Cashmere Ribbed Cardigan');
    });

    test('equality works correctly', () {
      final product1 = Product(
        id: '1',
        name: 'Cashmere Ribbed Cardigan',
        category: 'Cardigan',
        material: 'Cashmere',
        price: 285.00,
        img: 'https://example.com/cardigan.jpg',
      );

      final product2 = Product(
        id: '1',
        name: 'Cashmere Ribbed Cardigan',
        category: 'Cardigan',
        material: 'Cashmere',
        price: 285.00,
        img: 'https://example.com/cardigan.jpg',
      );

      expect(product1, equals(product2));
    });
  });
}
