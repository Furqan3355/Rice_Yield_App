import 'package:flutter/material.dart';
import 'package:rice_yield_app/core/constants/app_assets.dart';
import 'package:rice_yield_app/core/utils/app_colors.dart';

/// App logo on a primary-color background tile.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.width = 160,
    this.height = 160,
    this.assetPath = AppAssets.logoPrimary,
    this.fit = BoxFit.contain,
    this.borderRadius = 16,
    this.padding = 12,
  });

  final double width;
  final double height;
  final String assetPath;
  final BoxFit fit;
  final double borderRadius;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: EdgeInsets.all(padding),
      child: Image.asset(
        assetPath,
        fit: fit,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
