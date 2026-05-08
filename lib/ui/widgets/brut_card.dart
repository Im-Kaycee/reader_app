import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BrutCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const BrutCard({
    super.key,
    required this.child,
    this.borderColor,
    this.backgroundColor,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkSurface : AppColors.white;
    final defaultBorder = isDark ? AppColors.darkInk : AppColors.ink;
    final shadowColor = isDark ? AppColors.darkInk : AppColors.ink;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? defaultBg,
          border: Border.all(
            color: borderColor ?? defaultBorder,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}