import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String _selectedPayment = 'cod';

  final List<Map<String, dynamic>> _paymentMethods = [
    {'value': 'cod', 'label': 'Bayar di Tempat (COD)', 'icon': Icons.money},
    {'value': 'transfer', 'label': 'Transfer Bank', 'icon': Icons.account_balance},
    {'value': 'ewallet', 'label': 'E-Wallet (GoPay/OVO)', 'icon': Icons.phone_android},
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Map<String, String> _parseSpecs(String specs) {
    final parts = specs.split(' / ');
    if (parts.length >= 2) {
      return {'color': parts[0], 'size': parts[1]};
    }
    return {'color': specs, 'size': ''};
  }

  Future<bool> _validateStock() async {
    final cartState = ref.read(cartProvider);
    for (var data in cartState.items) {
      final item = data.item;
      final specs = _parseSpecs(item.specs);
      final color = specs['color'] ?? '';
      final size = specs['size'] ?? '';

      if (color.isEmpty || size.isEmpty) continue;

      try {
        final result = await ApiService.get('/products/${item.productId}/variants');
        final variants = result['variants'] ?? [];
        int stock = 0;
        for (var v in variants) {
          if (v['color'] == color && v['size'] == size) {
            stock = v['stock'] as int;
            break;
          }
        }
        if (stock < item.quantity) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.name} ($color/$size) stok tidak cukup. Stok: $stock'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return false;
        }
      } catch (_) {}
    }
    return true;
  }

  Future<void> _placeOrder() async {
    if (_addressController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Isi alamat dan nomor telepon'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final cartState = ref.read(cartProvider);
    if (cartState.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Keranjang kosong'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final stockValid = await _validateStock();
    if (!stockValid) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final items = cartState.items
          .map((data) {
            final specs = _parseSpecs(data.item.specs);
            return {
              'product_id': int.parse(data.item.productId),
              'quantity': data.item.quantity,
              'color': specs['color'] ?? '',
              'size': specs['size'] ?? '',
            };
          })
          .toList();

      await ApiService.post('/orders', body: {
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'payment_method': _selectedPayment,
        'items': items,
      });

      ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil!')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final shippingFee = cartState.subtotal < 250000 ? 15000.0 : 0.0;
    final totalPrice = cartState.subtotal + shippingFee;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alamat Pengiriman',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Alamat lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Nomor telepon',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Metode Pembayaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._paymentMethods.map((method) {
              final isSelected = _selectedPayment == method['value'];
              return GestureDetector(
                onTap: () => setState(() => _selectedPayment = method['value']),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(method['icon'],
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(method['label'],
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.primary,
                            )),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),
            const Text('Ringkasan Pesanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...cartState.items.map((data) {
              final item = data.item;
              final specs = _parseSpecs(item.specs);
              final color = specs['color'] ?? '';
              final size = specs['size'] ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name),
                          Text(
                            '$color / $size × ${item.quantity}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rp ${(item.price * item.quantity).toStringAsFixed(0)}',
                    ),
                  ],
                ),
              );
            }),
            const Divider(),
            _buildSummaryRow(context, 'Subtotal', 'Rp ${cartState.subtotal.toStringAsFixed(0)}'),
            _buildSummaryRow(
              context,
              'Ongkir',
              shippingFee == 0 ? 'GRATIS' : 'Rp ${shippingFee.toStringAsFixed(0)}',
              valueColor: shippingFee == 0 ? Colors.green : null,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(context, 'Total', 'Rp ${totalPrice.toStringAsFixed(0)}', isBold: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _placeOrder,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Bayar', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            color: isBold ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          )),
          Text(value, style: TextStyle(
            color: valueColor ?? Theme.of(context).colorScheme.primary,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          )),
        ],
      ),
    );
  }
}
