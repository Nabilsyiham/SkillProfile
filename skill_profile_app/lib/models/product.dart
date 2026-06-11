import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const Product._();

  const factory Product({
    required dynamic id,
    required String name,
    required String category,
    required String material,
    required dynamic price,
    required String img,
    @Default(false) bool isFlashSale,
    @Default(0) @JsonKey(name: 'discount_percent') int discountPercent,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  double get priceAsDouble {
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) return double.tryParse(price) ?? 0;
    return 0;
  }

  double get discountedPrice {
    if (discountPercent <= 0) return priceAsDouble;
    return priceAsDouble * (1 - discountPercent / 100);
  }
}

double parsePrice(dynamic price) {
  if (price is double) return price;
  if (price is int) return price.toDouble();
  if (price is String) return double.tryParse(price) ?? 0;
  return 0;
}
