import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';

@freezed
class Review with _$Review {
  const factory Review({
    required String id,
    required String userName,
    required int rating,
    required String comment,
    required DateTime date,
    String? userAvatar,
  }) = _Review;
}
