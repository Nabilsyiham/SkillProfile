import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final result = await ApiService.get('/admin/stats');
  return result;
});

final adminProductsProvider = FutureProvider<List<dynamic>>((ref) async {
  final result = await ApiService.get('/admin/products');
  if (result is List) return result;
  if (result is Map && result['data'] is List) return result['data'];
  return [];
});

final adminOrdersProvider = FutureProvider<List<dynamic>>((ref) async {
  final result = await ApiService.get('/admin/orders');
  if (result is List) return result;
  if (result is Map && result['data'] is List) return result['data'];
  return [];
});