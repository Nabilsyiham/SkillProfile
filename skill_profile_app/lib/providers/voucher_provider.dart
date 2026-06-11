import 'package:flutter_riverpod/flutter_riverpod.dart';

class Voucher {
  final String code;
  final String description;
  final double discountPercent;
  final double minPurchase;
  final double maxDiscount;

  const Voucher({
    required this.code,
    required this.description,
    required this.discountPercent,
    required this.minPurchase,
    required this.maxDiscount,
  });
}

final availableVouchersProvider = Provider<List<Voucher>>((ref) {
  return [
    const Voucher(
      code: 'NEWUSER10',
      description: 'Discount 10% for new users',
      discountPercent: 10,
      minPurchase: 0,
      maxDiscount: 50,
    ),
    const Voucher(
      code: 'FREESHIP',
      description: 'Free shipping on any purchase',
      discountPercent: 0,
      minPurchase: 0,
      maxDiscount: 0,
    ),
    const Voucher(
      code: 'SAVE20',
      description: 'Discount 20% min. purchase \$200',
      discountPercent: 20,
      minPurchase: 200,
      maxDiscount: 100,
    ),
    const Voucher(
      code: 'FLASH50',
      description: 'Discount 50% min. purchase \$500',
      discountPercent: 50,
      minPurchase: 500,
      maxDiscount: 200,
    ),
  ];
});
