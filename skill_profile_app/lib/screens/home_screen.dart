import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math';
import 'package:skill_profile_app/providers/cart_provider.dart';
import 'package:skill_profile_app/providers/products_provider.dart';
import 'package:skill_profile_app/providers/flash_sale_provider.dart';
import 'package:skill_profile_app/providers/recently_viewed_provider.dart';
import 'package:skill_profile_app/models/product.dart';
import 'package:skill_profile_app/screens/widgets/product_card.dart';
import 'package:skill_profile_app/screens/detail_screen.dart';
import 'package:skill_profile_app/screens/widgets/cached_image.dart';
import 'package:skill_profile_app/utils/responsive_helper.dart';
import 'package:skill_profile_app/screens/chat_screen.dart';
import 'package:skill_profile_app/screens/cart_screen.dart';
import 'package:skill_profile_app/providers/auth_provider.dart';
import 'package:skill_profile_app/screens/login_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = ResponsiveHelper.getMaxWidth(context);
    final padding = ResponsiveHelper.getHorizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: -0.5,
                ),
            children: [
              TextSpan(text: 'Features '),
              TextSpan(text: '& ', style: TextStyle(fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.secondary)),
              TextSpan(text: 'Found'),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: _buildCartBadge(context, ref),
            onPressed: () {
              final isLoggedIn = ref.read(authProvider).user != null;
              if (!isLoggedIn) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Login untuk mengakses keranjang')),
                );
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              final isLoggedIn = ref.read(authProvider).user != null;
              if (!isLoggedIn) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Login untuk mengakses chat')),
                );
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(flashSaleProductsProvider);
              ref.invalidate(productsProvider);
              ref.invalidate(recentlyViewedProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshed'), duration: Duration(seconds: 1)),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(flashSaleProductsProvider);
          ref.invalidate(productsProvider);
          ref.invalidate(recentlyViewedProvider);
          await Future<void>.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  _buildHeroSection(context),
                  _buildFlashSaleSection(context, ref, padding),
                  _buildNewArrivals(context, padding),
                  _buildFeaturedEssentials(context, ref, padding),
                  _buildRecommendedForYou(context, ref, padding),
                  _buildRecentlyViewed(context, ref, padding),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartBadge(BuildContext context, WidgetRef ref) {
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

  Widget _buildHeroSection(BuildContext context) {
    final heroHeight = ResponsiveHelper.isDesktop(context) ? 700.0 : 600.0;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedImage(
              img: 'https://i.pinimg.com/1200x/4c/a7/f1/4ca7f12a9040a85070d5fa920991aa12.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SS26 COLLECTION',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontSize: 10,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Dress with\nIntention',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            height: 1.1,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Explore refined silhouettes, organic fabrics, and timeless accessories from independent ateliers — crafted for the discerning modern wardrobe.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w300,
                          ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Text('EXPLORE THE COLLECTION'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashSaleSection(BuildContext context, WidgetRef ref, double padding) {
    final productsAsync = ref.watch(flashSaleProductsProvider);
    final endTime = ref.watch(flashSaleEndTimeProvider);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade400,
            Colors.red.shade400,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'HURRY UP!',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.red.shade600,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'FLASH SALE',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                _FlashCountdownTimer(endTime: endTime),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (_, __) => const Center(child: Text('Gagal memuat data', style: TextStyle(color: Colors.white))),
              data: (products) => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: padding),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _FlashSaleCard(product: products[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewArrivals(BuildContext context, double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.headlineLarge,
                      children: const [
                        TextSpan(text: 'New '),
                        TextSpan(text: 'Arrivals', style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "The season's most refined new pieces.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
              Text(
                'VIEW ALL',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10, decoration: TextDecoration.underline),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildBentoItem(
            context,
            'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=1200&q=80&fit=crop',
            'Eveningwear',
            'The Silk Evening Edit',
            height: 350,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBentoItem(
                  context,
                  'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600&q=80&fit=crop',
                  'Bags',
                  'Structured Leather Tote',
                  height: 200,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBentoItem(
                  context,
                  'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600&q=80&fit=crop',
                  'Shoes',
                  'Milan Ankle Boot',
                  height: 200,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoItem(BuildContext context, String img, String category, String title, {required double height}) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedImage(
                img: img,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedEssentials(BuildContext context, WidgetRef ref, double padding) {
    final productsAsync = ref.watch(productsProvider);
    final gridColumns = ResponsiveHelper.getGridColumns(context);
    final aspectRatio = ResponsiveHelper.getChildAspectRatio(context);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: padding),
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineLarge,
              children: const [
                TextSpan(text: 'Featured '),
                TextSpan(text: 'Essentials', style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wardrobe foundations selected for their timeless silhouette, elevated fabric, and quiet sophistication.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(height: 32),
          productsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (err, _) => Text('Error: $err'),
            data: (products) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridColumns,
                childAspectRatio: aspectRatio,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: products[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(product: products[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedForYou(BuildContext context, WidgetRef ref, double padding) {
    final productsAsync = ref.watch(productsProvider);
    final gridColumns = ResponsiveHelper.getGridColumns(context);
    final aspectRatio = ResponsiveHelper.getChildAspectRatio(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: padding),
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineLarge,
              children: const [
                TextSpan(text: 'Recommended '),
                TextSpan(text: 'for You', style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Curated picks based on your browsing style.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(height: 32),
          productsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (err, _) => Text('Error: $err'),
            data: (products) {
              final shuffled = List<Product>.from(products)..shuffle(Random());
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridColumns,
                  childAspectRatio: aspectRatio,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: shuffled.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: shuffled[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(product: shuffled[index]),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyViewed(BuildContext context, WidgetRef ref, double padding) {
    final products = ref.watch(recentlyViewedProvider);
    if (products.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineLarge,
              children: const [
                TextSpan(text: 'Recently '),
                TextSpan(text: 'Viewed', style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Products you recently explored.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 160,
                  child: ProductCard(
                    product: products[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(product: products[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}

class _FlashCountdownTimer extends StatefulWidget {
  final DateTime endTime;

  const _FlashCountdownTimer({required this.endTime});

  @override
  State<_FlashCountdownTimer> createState() => _FlashCountdownTimerState();
}

class _FlashCountdownTimerState extends State<_FlashCountdownTimer> {
  late Timer _timer;
  late Duration _timeRemaining;

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTimeRemaining());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    setState(() {
      _timeRemaining = widget.endTime.difference(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hours = _timeRemaining.inHours;
    final minutes = (_timeRemaining.inMinutes % 60);
    final seconds = (_timeRemaining.inSeconds % 60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeBlock(hours.toString().padLeft(2, '0')),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(':', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          _buildTimeBlock(minutes.toString().padLeft(2, '0')),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(':', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          _buildTimeBlock(seconds.toString().padLeft(2, '0')),
        ],
      ),
    );
  }

  Widget _buildTimeBlock(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _FlashSaleCard extends StatelessWidget {
  final Product product;

  const _FlashSaleCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final discountPercent = product.discountPercent;
    final discountedPrice = product.discountedPrice;

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedImage(
                    img: product.img,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '-$discountPercent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (discountPercent > 0) ...[
                  Text(
                    'Rp.${product.priceAsDouble.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    'Rp.${discountedPrice.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.red.shade600,
                    ),
                  ),
                ] else
                  Text(
                    'Rp.${product.priceAsDouble.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.red.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
