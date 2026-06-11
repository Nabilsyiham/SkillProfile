import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_profile_app/models/product.dart';
import 'package:skill_profile_app/screens/widgets/cached_image.dart';
import 'package:skill_profile_app/utils/responsive_helper.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final padding = isDesktop ? 12.0 : isTablet ? 10.0 : 8.0;
    final categoryFontSize = isDesktop ? 11.0 : isTablet ? 10.0 : 9.0;
    final nameFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : 13.0;
    final priceFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : 13.0;
    final newFontSize = isDesktop ? 10.0 : isTablet ? 9.0 : 8.0;
    final spacing = isDesktop ? 16.0 : isTablet ? 14.0 : 12.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.surface),
        ),
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedImage(
                  img: product.img,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: spacing),
            Text(
              product.category.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: categoryFontSize,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: padding * 0.5),
            Text(
              product.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: nameFontSize,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: padding * 0.5),
            Text(
              'Rp.${product.priceAsDouble.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: priceFontSize,
              ),
            ),
            if (product.priceAsDouble > 100)
              Container(
                margin: EdgeInsets.only(top: padding * 0.5),
                padding: EdgeInsets.symmetric(horizontal: padding * 0.5, vertical: padding * 0.25),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'FREE SHIPPING',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: newFontSize,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}