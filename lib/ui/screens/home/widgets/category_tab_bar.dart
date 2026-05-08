import 'package:flutter/material.dart';
import '../../../../core/constants/feed_sources.dart';
import '../../../../ui/theme/app_theme.dart';

class CategoryTabBar extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;

  const CategoryTabBar({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: kCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = kCategories[index];
          final isSelected = cat == selected;
          final accent = AppColors.forCategory(cat);

          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.ink : AppColors.cream,
                border: Border.all(color: AppColors.ink, width: 2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: accent,
                          offset: const Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                cat.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: isSelected ? AppColors.cream : AppColors.ink,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}