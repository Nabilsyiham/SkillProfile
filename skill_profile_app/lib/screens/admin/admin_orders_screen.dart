import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../services/api_service.dart';
import '../../screens/login_screen.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  Timer? _pollTimer;

  final Map<String, String> _statusLabels = {
    'pending': 'Menunggu',
    'processing': 'Diproses',
    'shipped': 'Dikirim',
    'delivered': 'Selesai',
    'cancelled': 'Dibatalkan',
  };

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      ref.invalidate(adminOrdersProvider);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.amber;
    }
  }

  Future<void> _updateStatus(dynamic orderId, String newStatus) async {
    try {
      await ApiService.put('/admin/orders/$orderId/status', body: {
        'status': newStatus,
      });
      ref.invalidate(adminOrdersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status diperbarui ke ${_statusLabels[newStatus] ?? newStatus}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pesanan'),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) {
          final isAuth = e.toString().contains('401') || e.toString().contains('Unauthenticated');
          if (isAuth) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Session expired, silakan login lagi'), backgroundColor: Colors.red),
              );
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            });
            return const SizedBox();
          }
          return Center(child: Text('Error: $e'));
        },
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('Belum ada pesanan'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final statusColor = _getStatusColor(order['status'] ?? 'pending');

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor,
                    child: const Icon(Icons.receipt, color: Colors.white),
                  ),
                  title: Text('Order #${order['id']}'),
                  subtitle: Text(
                    'Rp ${order['total_price']} • ${_statusLabels[order['status']] ?? order['status']}',
                    style: TextStyle(color: statusColor),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer: ${order['user']?['name'] ?? 'N/A'}'),
                          Text('Address: ${order['address']}'),
                          Text('Phone: ${order['phone']}'),
                          Text('Payment: ${order['payment_method'] ?? 'N/A'}'),
                          const SizedBox(height: 8),
                          const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                          if (order['items'] != null)
                            ...List<Widget>.from(
                              (order['items'] as List).map(
                                (item) => Text(
                                  '  - ${item['product']?['name'] ?? 'Product'} x${item['quantity']} @ Rp ${item['price']}',
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('Status: '),
                              DropdownButton<String>(
                                value: order['status'],
                                items: _statusLabels.entries
                                    .map((e) => DropdownMenuItem(
                                          value: e.key,
                                          child: Text(e.value),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    _updateStatus(order['id'], value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
