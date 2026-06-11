import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';
part 'address.g.dart';

@freezed
class Address with _$Address {
  const factory Address({
    required dynamic id,
    @JsonKey(name: 'user_id') required dynamic userId,
    @Default('Rumah') String label,
    @JsonKey(name: 'recipient_name') required String recipientName,
    required String phone,
    required String address,
    required String city,
    required String province,
    @JsonKey(name: 'postal_code') String? postalCode,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
}
