import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review.dart';
import '../services/api_service.dart';

final reviewsProvider = Provider<Map<String, List<Review>>>((ref) {
  return {
    '1': [
      Review(
        id: 'r1',
        userName: 'Sarah M.',
        rating: 5,
        comment: 'Amazing quality! The fabric is so soft and the fit is perfect.',
        date: DateTime(2026, 5, 20),
      ),
      Review(
        id: 'r2',
        userName: 'John D.',
        rating: 4,
        comment: 'Great product, slightly oversized but I like it.',
        date: DateTime(2026, 5, 15),
      ),
    ],
    '2': [
      Review(
        id: 'r3',
        userName: 'Emily R.',
        rating: 5,
        comment: 'Love these trousers! So comfortable and stylish.',
        date: DateTime(2026, 5, 10),
      ),
    ],
    '3': [
      Review(
        id: 'r4',
        userName: 'Michael K.',
        rating: 5,
        comment: 'Beautiful bag, exactly as pictured. Fast shipping!',
        date: DateTime(2026, 5, 5),
      ),
      Review(
        id: 'r5',
        userName: 'Lisa T.',
        rating: 4,
        comment: 'Good quality leather. A bit smaller than expected.',
        date: DateTime(2026, 4, 28),
      ),
    ],
  };
});

final averageRatingProvider = Provider.family<double, String>((ref, productId) {
  final reviews = ref.watch(reviewsProvider);
  final productReviews = reviews[productId];
  if (productReviews == null || productReviews.isEmpty) return 0;
  double total = 0;
  for (var review in productReviews) {
    total += review.rating;
  }
  return total / productReviews.length;
});

final productReviewsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, productId) async {
  final result = await ApiService.get('/products/$productId/reviews');
  return result;
});
