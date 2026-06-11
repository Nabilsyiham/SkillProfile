import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/address.dart';
import '../services/api_service.dart';

class AddressNotifier extends StateNotifier<AsyncValue<List<Address>>> {
  AddressNotifier() : super(const AsyncValue.loading()) {
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    state = const AsyncValue.loading();
    try {
      final result = await ApiService.get('/addresses');
      final list = (result['addresses'] as List)
          .map((e) => Address.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> addAddress(Map<String, dynamic> data) async {
    try {
      await ApiService.post('/addresses', body: data);
      await loadAddresses();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateAddress(dynamic id, Map<String, dynamic> data) async {
    try {
      await ApiService.put('/addresses/$id', body: data);
      await loadAddresses();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAddress(dynamic id) async {
    try {
      await ApiService.delete('/addresses/$id');
      await loadAddresses();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setDefault(dynamic id) async {
    try {
      await ApiService.put('/addresses/$id/default');
      await loadAddresses();
      return true;
    } catch (_) {
      return false;
    }
  }

  Address? get defaultAddress {
    final addresses = state.valueOrNull ?? [];
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }
}

final addressProvider =
    StateNotifierProvider<AddressNotifier, AsyncValue<List<Address>>>((ref) {
  return AddressNotifier();
});
