import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../services/api_service.dart';
import '../../screens/login_screen.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              final statusColor = order['status'] == 'completed'
                  ? Colors.green
                  : order['status'] == 'shipped'
                      ? Colors.blue
                      : Colors.orange;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor,
                    child: const Icon(Icons.receipt, color: Colors.white),
                  ),
                  title: Text('Order #${order['id']}'),
                  subtitle: Text(
                    'Rp ${order['total_price']} • ${order['status']}',
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
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Status: '),
                              DropdownButton<String>(
                                value: order['status'],
                                items: ['pending', 'shipped', 'completed']
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                    .toList(),
                                onChanged: (value) async {
                                  if (value != null) {
                                    await ApiService.put(
                                      '/admin/orders/${order['id']}/status',
                                      body: {'status': value},
                                    );
                                    ref.invalidate(adminOrdersProvider);
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
