import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../providers/address_provider.dart';
import '../models/address.dart';
import '../services/api_service.dart';
import 'address_list_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isLoading = false;
  String _selectedPayment = 'cod';
  Address? _selectedAddress;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'value': 'cod', 'label': 'Bayar di Tempat (COD)', 'icon': Icons.money},
    {'value': 'transfer', 'label': 'Transfer Bank', 'icon': Icons.account_balance},
    {'value': 'ewallet', 'label': 'E-Wallet (GoPay/OVO)', 'icon': Icons.phone_android},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addr = ref.read(addressProvider.notifier).defaultAddress;
      if (addr != null && _selectedAddress == null) {
        setState(() => _selectedAddress = addr);
      }
    });
  }

  Map<String, String> _parseSpecs(String specs) {
    final parts = specs.split(' / ');
    if (parts.length >= 2) {
      return {'color': parts[0].trim(), 'size': parts[1].trim()};
    }
    return {'color': specs, 'size': ''};
  }

  Future<bool> _validateStock() async {
    final cartState = ref.read(cartProvider);
    for (var data in cartState.items) {
      try {
        final result = await ApiService.get('/products/${data.item.productId}/variants');
        final variants = result is List ? result : (result['variants'] ?? []);
        final specs = _parseSpecs(data.item.specs);
        bool found = false;
        for (var v in variants) {
          if (v['color']?.toString().toUpperCase() == specs['color']?.toUpperCase() &&
              v['size']?.toString().toUpperCase() == specs['size']?.toUpperCase() &&
              (v['stock'] ?? 0) >= data.item.quantity) {
            found = true;
            break;
          }
        }
        if (!found) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${data.item.name} (${specs['color']}/${specs['size']}) stok tidak cukup')),
            );
          }
          return false;
        }
      } catch (_) {}
    }
    return true;
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih alamat pengiriman terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (!await _validateStock()) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final cartState = ref.read(cartProvider);
      final items = cartState.items.map((data) {
        final specs = _parseSpecs(data.item.specs);
        return {
          'product_id': int.parse(data.item.productId),
          'quantity': data.item.quantity,
          'color': specs['color'],
          'size': specs['size'],
        };
      }).toList();

      await ApiService.post('/orders', body: {
        'address_id': _selectedAddress!.id,
        'phone': _selectedAddress!.phone,
        'payment_method': _selectedPayment,
        'items': items,
      });

      await ref.read(cartProvider.notifier).clearCart();
      await ref.read(addressProvider.notifier).loadAddresses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil!')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Alamat Pengiriman', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _selectedAddress != null
              ? InkWell(
                  onTap: () async {
                    final addr = await Navigator.push<Address>(
                      context,
                      MaterialPageRoute(builder: (_) => const AddressListScreen(selectMode: true)),
                    );
                    if (addr != null) setState(() => _selectedAddress = addr);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.primary, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(_selectedAddress!.label,
                                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    if (_selectedAddress!.isDefault)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('Default', style: TextStyle(color: Colors.green, fontSize: 10)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(_selectedAddress!.recipientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(_selectedAddress!.phone),
                                const SizedBox(height: 4),
                                Text(
                                  '${_selectedAddress!.address}, ${_selectedAddress!.city}, ${_selectedAddress!.province}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: () async {
                    final addr = await Navigator.push<Address>(
                      context,
                      MaterialPageRoute(builder: (_) => const AddressListScreen(selectMode: true)),
                    );
                    if (addr != null) setState(() => _selectedAddress = addr);
                  },
                  icon: const Icon(Icons.add_location),
                  label: const Text('Tambah Alamat Pengiriman'),
                ),

          const SizedBox(height: 24),

          Text('Metode Pembayaran', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._paymentMethods.map((pm) => RadioListTile<String>(
                title: Row(
                  children: [
                    Icon(pm['icon'] as IconData, size: 20),
                    const SizedBox(width: 8),
                    Text(pm['label'] as String),
                  ],
                ),
                value: pm['value'] as String,
                groupValue: _selectedPayment,
                onChanged: (v) => setState(() => _selectedPayment = v!),
              )),

          const SizedBox(height: 24),

          Text('Ringkasan Pesanan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...cartState.items.map((data) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data.item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                  Text('${data.item.specs} x${data.item.quantity}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ],
                              ),
                            ),
                            Text('Rp${(data.item.price * data.item.quantity).toStringAsFixed(0)}'),
                          ],
                        ),
                      )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text('Rp${cartState.subtotal.toStringAsFixed(0)}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ongkos Kirim'),
                      Text(cartState.shippingFee > 0
                          ? 'Rp${cartState.shippingFee.toStringAsFixed(0)}'
                          : 'GRATIS'),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Rp${cartState.total.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.primary,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _isLoading ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Buat Pesanan', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
