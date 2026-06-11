import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String role,
    String? firstName,
    String? lastName,
    String? avatarUrl,
  }) = _User;

  const User._();

  String get name => [firstName, lastName].where((n) => n != null && n.isNotEmpty).join(' ');

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
