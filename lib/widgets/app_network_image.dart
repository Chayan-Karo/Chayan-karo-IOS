import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final double borderRadius;
  final bool forceRefresh; // optional control

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.forceRefresh = false,
  });

  @override
  Widget build(BuildContext context) {
    final cacheManager = DefaultCacheManager();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,

        // 🔥 CACHE CONTROL (important)
        cacheManager: cacheManager,
        useOldImageOnUrlChange: true,

        // 🚀 KEY PRO: no flicker after first load
        fadeInDuration: const Duration(milliseconds: 150),
        fadeOutDuration: const Duration(milliseconds: 50),

        fit: fit,
        width: width,
        height: height,

        // ⚡ FIRST LOAD ONLY (minimal UI)
        placeholder: (context, url) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
          );
        },

        // ❌ ERROR STATE
        errorWidget: (context, url, error) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image),
          );
        },
      ),
    );
  }
}