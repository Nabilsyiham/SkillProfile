import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

const String apiUrl = 'http://localhost:8000/api';

final flashSaleProductsProvider = FutureProvider<List<Product>>((ref) async {
  final response = await http.get(Uri.parse('$apiUrl/products-flash-sale'));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Product.fromJson(json)).toList();
  } else {
    throw Exception('Gagal mengambil data flash sale');
  }
});

final flashSaleEndTimeProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + 1);
});
