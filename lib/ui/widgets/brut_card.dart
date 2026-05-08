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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.white,
          border: Border.all(
            color: borderColor ?? AppColors.ink,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink,
              offset: const Offset(4, 4),
              blurRadius: 0,       // hard shadow — the whole vibe
            ),
          ],
        ),
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}