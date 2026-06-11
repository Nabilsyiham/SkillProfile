import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_profile_app/providers/cart_provider.dart';
import 'package:skill_profile_app/providers/recently_viewed_provider.dart';
import 'package:skill_profile_app/providers/review_provider.dart';
import 'package:skill_profile_app/providers/wishlist_provider.dart';
import 'package:skill_profile_app/models/product.dart';
import 'package:skill_profile_app/models/cart_item.dart';
import 'package:skill_profile_app/screens/widgets/cached_image.dart';
import 'package:skill_profile_app/screens/review_form_screen.dart';
import 'package:skill_profile_app/utils/responsive_helper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skill_profile_app/providers/auth_provider.dart';
import 'package:skill_profile_app/screens/login_screen.dart';
import 'package:skill_profile_app/services/api_service.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final Product? product;

  const DetailScreen({super.key, this.product});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  String _selectedColor = 'Charcoal';
  String _selectedSize = 'S';

  List<dynamic> _variants = [];

  static const _defaultColors = ['Charcoal', 'Warm Earth', 'Bone White'];
  static const _defaultSizes = ['XS', 'S', 'M', 'L'];

  @override
  void initState() {
    super.initState();
    _loadVariants();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final product = widget.product;
      if (product != null) {
        ref.read(recentlyViewedProvider.notifier).addProduct(product);
      }
    });
  }

  Future<void> _loadVariants() async {
    final product = widget.product;
    if (product == null) return;
    try {
      final result = await ApiService.get('/products/${product.id}/variants');
      if (mounted) {
        setState(() {
          _variants = result['variants'] ?? [];
          if (_variants.isNotEmpty) {
            final colors = _variants.map((v) => v['color'] as String).toSet().toList();
            final sizes = _variants.map((v) => v['size'] as String).toSet().toList();
            if (colors.isNotEmpty) _selectedColor = colors.first;
            if (sizes.isNotEmpty) _selectedSize = sizes.first;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _variants = [];
        });
      }
    }
  }

  List<String> get _availableColors {
    if (_variants.isNotEmpty) {
      return _variants.map((v) => v['color'] as String).toSet().toList();
    }
    return _defaultColors;
  }

  List<String> get _availableSizes {
    if (_variants.isNotEmpty) {
      return _variants.map((v) => v['size'] as String).toSet().toList();
    }
    return _defaultSizes;
  }

  int _getStock(String color, String size) {
    for (var v in _variants) {
      if (v['color'] == color && v['size'] == size) {
        return v['stock'] as int;
      }
    }
    return 10;
  }

  bool get _isSelectedVariantAvailable {
    return _getStock(_selectedColor, _selectedSize) > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _buildCartBadge(context),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: ResponsiveHelper.getMaxWidth(context)),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getHorizontalPadding(context),
                vertical: 24.0,
              ),
              child: ResponsiveHelper.isDesktop(context)
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildImageSection()),
                        const SizedBox(width: 48),
                        Expanded(flex: 5, child: _buildInfoSection()),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageSection(),
                        const SizedBox(height: 32),
                        _buildInfoSection(),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final product = widget.product;
    if (product == null) return const SizedBox.shrink();
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: isDesktop ? 3 / 4 : 4 / 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CachedImage(
                    img: product.img,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.surface),
                    ),
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'NEW ARRIVAL',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 1.5,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    final product = widget.product;
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final double titleSize = isDesktop ? 32 : 24;
    final double priceSize = isDesktop ? 24 : 20;
    final double verticalSpacing = isDesktop ? 16 : 12;

    final String productName = product?.name ?? 'Structured Wool Overcoat';
    final double productPrice = product?.priceAsDouble ?? 495.00;
    final String productCategory = product?.category.toUpperCase() ?? 'FASHION & TAILORING';

    final stock = _getStock(_selectedColor, _selectedSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          productCategory,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
        ),
        SizedBox(height: verticalSpacing),
        Text(
          productName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w300,
                fontSize: titleSize,
              ),
        ),
        SizedBox(height: verticalSpacing),
        Text(
          'Rp.${productPrice.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: priceSize,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'FREE SHIPPING',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.local_shipping, size: 16, color: Colors.green),
            const SizedBox(width: 6),
            Text(
              'Free shipping on orders over Rp100.000',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Divider(color: Theme.of(context).colorScheme.surface),
        const SizedBox(height: 24),
        Text(
          product?.material ?? 'Crafted from premium Italian virgin wool, this structured overcoat offers a tailored silhouette.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
        ),
        const SizedBox(height: 24),

        // Color selector
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
            children: [
              const TextSpan(text: 'COLOR: '),
              TextSpan(
                text: _selectedColor,
                style: TextStyle(fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.secondary, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: _availableColors.map((color) {
            final isAvailable = _getStock(color, _selectedSize) > 0;
            return GestureDetector(
              onTap: isAvailable
                  ? () {
                      setState(() {
                        _selectedColor = color;
                      });
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedColor == color
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                    width: _selectedColor == color ? 2 : 1,
                  ),
                  color: !isAvailable ? Colors.grey.withValues(alpha: 0.1) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      color,
                      style: TextStyle(
                        color: isAvailable
                            ? (_selectedColor == color ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface)
                            : Colors.grey,
                        fontWeight: _selectedColor == color ? FontWeight.w600 : FontWeight.w400,
                        decoration: isAvailable ? null : TextDecoration.lineThrough,
                      ),
                    ),
                    if (!isAvailable) ...[
                      const SizedBox(width: 6),
                      const Text('Sold Out', style: TextStyle(color: Colors.red, fontSize: 11)),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Size selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SIZE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
            ),
            Text(
              'SIZE GUIDE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: _availableSizes.map((size) {
            final isAvailable = _getStock(_selectedColor, size) > 0;
            return GestureDetector(
              onTap: isAvailable
                  ? () {
                      setState(() {
                        _selectedSize = size;
                      });
                    }
                  : null,
              child: Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _selectedSize == size
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                    width: _selectedSize == size ? 2 : 1,
                  ),
                  color: !isAvailable ? Colors.grey.withValues(alpha: 0.1) : null,
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      size,
                      style: TextStyle(
                        color: isAvailable
                            ? (_selectedSize == size ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface)
                            : Colors.grey,
                        fontWeight: _selectedSize == size ? FontWeight.w600 : FontWeight.w400,
                        decoration: isAvailable ? null : TextDecoration.lineThrough,
                      ),
                    ),
                    if (!isAvailable)
                      const Text('Sold Out', style: TextStyle(color: Colors.red, fontSize: 9)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // Stock info
        const SizedBox(height: 16),
        if (stock > 0)
          Text(
            'Stok tersisa: $stock',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: stock <= 5 ? Colors.orange : Theme.of(context).colorScheme.secondary,
              fontWeight: stock <= 5 ? FontWeight.w600 : FontWeight.w400,
            ),
          )
        else
          const Text(
            'Stok habis untuk kombinasi ini',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),

        const SizedBox(height: 32),

        // Add to cart button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSelectedVariantAvailable
                ? () {
                    final isLoggedIn = ref.read(authProvider).user != null;
                    if (!isLoggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login untuk menambahkan ke keranjang')),
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      return;
                    }
                    ref.read(cartProvider.notifier).addItem(
                      CartItem(
                        id: DateTime.now().toString(),
                        productId: product!.id.toString(),
                        name: product.name,
                        specs: '${product.category} / $_selectedSize / $_selectedColor',
                        price: product.priceAsDouble,
                        quantity: 1,
                        img: product.img,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.name} ditambahkan ke keranjang')),
                    );
                  }
                : null,
            child: Text(_isSelectedVariantAvailable ? 'ADD TO SHOPPING BAG' : 'SOLD OUT'),
          ),
        ),
        const SizedBox(height: 24),

        // Wishlist & Share
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer(
              builder: (context, ref, child) {
                final isInWishlist = product != null && ref.watch(wishlistProvider).any((p) => p.id == product.id);
                return TextButton.icon(
                  onPressed: product != null
                      ? () async {
                          final isLoggedIn = ref.read(authProvider).user != null;
                          if (!isLoggedIn) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Login untuk menambahkan ke wishlist')),
                            );
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                            return;
                          }
                          if (isInWishlist) {
                            await ref.read(wishlistProvider.notifier).removeItem(product.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Removed from wishlist')),
                              );
                            }
                          } else {
                            await ref.read(wishlistProvider.notifier).addItem(product);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added to wishlist')),
                              );
                            }
                          }
                        }
                      : null,
                  icon: Icon(
                    isInWishlist ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: isInWishlist ? Colors.redAccent : Theme.of(context).colorScheme.secondary,
                  ),
                  label: Text(
                    isInWishlist ? 'REMOVE FROM WISHLIST' : 'ADD TO WISHLIST',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isInWishlist ? Colors.redAccent : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: () {
                Share.share('Check out ${product?.name ?? "Product"} at Rp${product?.priceAsDouble.toStringAsFixed(0) ?? "0"} - Features & Found');
              },
              icon: Icon(Icons.share_outlined, size: 18, color: Theme.of(context).colorScheme.secondary),
              label: Text(
                'SHARE PRODUCT',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Divider(color: Theme.of(context).colorScheme.surface),
        const SizedBox(height: 16),
        _buildSpecRow(context, 'Materials', product?.material ?? '100% Organic Virgin Wool'),
        _buildSpecRow(context, 'Origin', 'Sustainably hand-finished in Milan, Italy'),
        _buildSpecRow(context, 'Care Instructions', 'Dry Clean Only', border: false),
        const SizedBox(height: 32),
        _buildReviewSection(),
      ],
    );
  }

  Widget _buildReviewSection() {
    final product = widget.product;
    final productId = product?.id.toString() ?? '1';
    final reviews = ref.watch(reviewsProvider);
    final productReviews = reviews[productId] ?? [];
    final avgRating = ref.watch(averageRatingProvider(productId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Theme.of(context).colorScheme.surface),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CUSTOMER REVIEWS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
            ),
            Text(
              '${productReviews.length} review${productReviews.length != 1 ? 's' : ''}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ...List.generate(5, (index) {
              return Icon(
                index < avgRating.round()
                    ? Icons.star
                    : (index < avgRating
                        ? Icons.star_half
                        : Icons.star_border),
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              );
            }),
            const SizedBox(width: 8),
            Text(
              avgRating.toStringAsFixed(1),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReviewFormScreen(
                    productId: int.tryParse(productId) ?? 1,
                    productName: product?.name ?? 'Product',
                  ),
                ),
              );
              if (result == true) {
                ref.invalidate(reviewsProvider);
              }
            },
            icon: const Icon(Icons.rate_review_outlined, size: 18),
            label: const Text('TULIS REVIEW'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (productReviews.isEmpty)
          Text(
            'No reviews yet.',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          )
        else
          ...productReviews.map((review) => _buildReviewItem(review)),
      ],
    );
  }

  Widget _buildReviewItem(review) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.surface)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: Text(
                  review.userName[0].toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${review.date.day}/${review.date.month}/${review.date.year}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    color: Theme.of(context).colorScheme.primary,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartBadge(BuildContext context) {
    final totalItems = ref.watch(cartProvider.select((s) => s.totalItems));
    if (totalItems == 0) {
      return const Icon(Icons.shopping_bag_outlined);
    }
    return Badge(
      label: Text('$totalItems'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.shopping_bag_outlined),
    );
  }

  Widget _buildSpecRow(BuildContext context, String label, String value, {bool border = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: border ? Border(bottom: BorderSide(color: Theme.of(context).colorScheme.surface)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.primary)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
