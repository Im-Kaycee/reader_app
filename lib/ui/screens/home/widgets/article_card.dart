import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../data/models/article.dart';
import '../../../../ui/theme/app_theme.dart';
import '../../../../ui/widgets/brut_card.dart';
import '../../reader/reader_screen.dart';
import '../../../../ui/utils/transitions.dart';
class ArticleCard extends StatefulWidget {
  final Article article;

  const ArticleCard({super.key, required this.article});

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
  late bool _isRead;

  @override
  void initState() {
    super.initState();
    _isRead = widget.article.isRead;
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final accent = AppColors.forCategory(article.category);
    final hasImage = article.imageUrl != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: BrutCard(
        backgroundColor: _isRead ? AppColors.paper : AppColors.white,
        onTap: () async {
         await Navigator.of(context).push(
            SlideUpRoute(page: ReaderScreen(article: article)),
          );
          // Mark as read when returning from reader
          if (!_isRead) {
            setState(() => _isRead = true);
          }
        },
        child: hasImage
            ? _buildWithImage(article, accent)
            : _buildTextOnly(article, accent),
      ),
    );
  }

  // Layout when article has an image
  Widget _buildWithImage(Article article, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ClipRect(
          child: CachedNetworkImage(
            imageUrl: article.imageUrl!,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) =>
                _buildTextOnly(article, accent),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(14),
          child: _buildCardBody(article, accent),
        ),
      ],
    );
  }

  // Layout when article has no image — intentional text-only design
  Widget _buildTextOnly(Article article, Color accent) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left accent bar
          Container(
            width: 4,
            height: 80,
            color: accent,
            margin: const EdgeInsets.only(right: 14, top: 2),
          ),

          // Content
          Expanded(child: _buildCardBody(article, accent)),
        ],
      ),
    );
  }

  Widget _buildCardBody(Article article, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row — source badge + read indicator
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4,
              ),
              color: accent,
              child: Text(
                article.sourceName.toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.labelColorFor(accent),
                ),
              ),
            ),
            const Spacer(),
            // Unread dot
            if (!_isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ink, width: 1),
                ),
              ),
            if (article.isBookmarked) ...[
              const SizedBox(width: 6),
              const Icon(Icons.bookmark, size: 14, color: AppColors.ink),
            ],
          ],
        ),

        const SizedBox(height: 10),

        // Title — slightly muted if read
        Text(
          article.title,
          style: AppTextStyles.cardTitle.copyWith(
            color: _isRead
                ? const Color(0xFF666666)
                : AppColors.ink,
          ),
        ),

        // Description
        if (article.description != null) ...[
          const SizedBox(height: 6),
          Text(
            article.description!,
            style: AppTextStyles.muted,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: 10),

        // Meta row
        Row(
          children: [
            Text(
              _formatDate(article.publishedAt),
              style: AppTextStyles.muted,
            ),
            const SizedBox(width: 6),
            const Text('·',
                style: TextStyle(color: Color(0xFF888888))),
            const SizedBox(width: 6),
            Text(
              '${article.readTimeMinutes} min read',
              style: AppTextStyles.muted,
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}