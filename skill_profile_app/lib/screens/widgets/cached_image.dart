import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String img;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? cacheKey;

  const CachedImage({
    super.key,
    required this.img,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.cacheKey,
  });

  @override
  Widget build(BuildContext context) {
    final url = cacheKey != null
        ? (img.contains('?') ? '$img&_v=$cacheKey' : '$img?v=$cacheKey')
        : img;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Theme.of(context).colorScheme.surface,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.network(
          url,
          fit: fit,
          width: width,
          height: height,
          gaplessPlayback: true,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: width,
              height: height,
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 32,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
