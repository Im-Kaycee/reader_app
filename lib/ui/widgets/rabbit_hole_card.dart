import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/article.dart';
import '../../ui/theme/app_theme.dart';
import '../screens/reader/reader_screen.dart';
import '../utils/transitions.dart';

class RabbitHoleCard extends StatelessWidget {
  final Article article;

  const RabbitHoleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.forCategory(article.category);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          SlideUpRoute(page: ReaderScreen(article: article)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: AppColors.ink,
          border: Border.all(color: AppColors.ink, width: 2),
          boxShadow: [
            BoxShadow(
              color: accent,
              offset: const Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8,
              ),
              color: accent,
              child: Row(
                children: [
                  const Text('🕳️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Text(
                    'TODAY\'S RABBIT HOLE',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.labelColorFor(accent),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Image
            if (article.imageUrl != null)
              CachedNetworkImage(
                imageUrl: article.imageUrl!,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4,
                    ),
                    color: accent.withOpacity(0.2),
                    child: Text(
                      article.sourceName.toUpperCase(),
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.cream,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Title
                  Text(
                    article.title,
                    style: AppTextStyles.cardTitle.copyWith(
                      color: AppColors.cream,
                      fontSize: 19,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Description
                  if (article.description != null)
                    Text(
                      article.description!,
                      style: AppTextStyles.muted.copyWith(
                        color: const Color(0xFFAAAAAA),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 14),

                  // Meta + CTA
                  Row(
                    children: [
                      Text(
                        '${article.readTimeMinutes} min read',
                        style: AppTextStyles.muted.copyWith(
                          color: const Color(0xFFAAAAAA),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: accent,
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.cream,
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          'GO DEEP →',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppColors.labelColorFor(accent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}