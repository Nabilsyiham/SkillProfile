import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_profile_app/providers/cart_provider.dart';
import 'package:skill_profile_app/screens/checkout_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  void _updateQty(String productId, int delta) {
    ref.read(cartProvider.notifier).updateQuantity(productId, delta);
  }

  void _removeItem(String productId) {
    ref.read(cartProvider.notifier).removeItem(productId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shopping Bag',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
      body: state.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 24),
                  Text('Your shopping bag is empty.', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.secondary)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('GO SHOP'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                          children: const [
                            TextSpan(text: 'Your\n'),
                            TextSpan(text: 'Shopping Bag', style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w400)),
                          ],
                        ),
                      ),
                      Text(
                        '${state.totalItems} ITEM${state.totalItems == 1 ? '' : 'S'}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.items.length,
                    separatorBuilder: (context, index) => Divider(color: Theme.of(context).colorScheme.surface, height: 48),
                    itemBuilder: (context, index) {
                      final data = state.items[index];
                      final item = data.item;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(context).colorScheme.surface),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(item.img, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.image, color: Theme.of(context).colorScheme.secondary)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.w300,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.specs,
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Rp.${item.price.toStringAsFixed(0)}',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.surface,
                                        border: Border.all(color: Theme.of(context).colorScheme.surface),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove, size: 16),
                                            onPressed: () => _updateQty(item.productId, -1),
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            constraints: const BoxConstraints(),
                                          ),
                                          Text(
                                            '${item.quantity}',
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add, size: 16),
                                            onPressed: () => _updateQty(item.productId, 1),
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => _removeItem(item.productId),
                                      icon: Icon(Icons.delete_outline, size: 16, color: Theme.of(context).colorScheme.secondary),
                                      label: Text(
                                        'REMOVE',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.surface),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ORDER SUMMARY',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 24),
                        _buildSummaryRow(context, 'Subtotal', 'Rp.${state.subtotal.toStringAsFixed(0)}'),
                        _buildSummaryRow(
                          context,
                          'Shipping',
                          state.shippingFee == 0 ? 'GRATIS' : 'Rp.${state.shippingFee.toStringAsFixed(0)}',
                          valueColor: state.shippingFee == 0 ? Colors.green : Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Divider(color: Theme.of(context).colorScheme.surface),
                        const SizedBox(height: 16),
                        _buildSummaryRow(context, 'Total', 'Rp.${state.total.toStringAsFixed(0)}', isBold: true),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                              );
                            },
                            child: const Text('PROCEED TO CHECKOUT'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '* Free shipping applies for orders above Rp250.000.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.secondary, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Theme.of(context).colorScheme.primary,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
