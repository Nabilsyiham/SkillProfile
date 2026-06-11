import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

const String apiUrl = 'http://localhost:8000/api';

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final response = await http.get(Uri.parse('$apiUrl/products'));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Product.fromJson(json)).toList();
  } else {
    throw Exception('Gagal mengambil data produk');
  }
});
