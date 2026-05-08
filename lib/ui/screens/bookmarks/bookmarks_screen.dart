import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/feed_provider.dart';
import '../../../ui/theme/app_theme.dart';
import '../home/widgets/article_card.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SAVED.', style: AppTextStyles.headline),
                  const SizedBox(height: 4),
                  Text(
                    '${bookmarks.length} article${bookmarks.length == 1 ? '' : 's'}',
                    style: AppTextStyles.muted,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Container(height: 2, color: AppColors.ink),

            // List
            Expanded(
              child: bookmarks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.ink, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.ink,
                                  offset: Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.bookmark_border,
                                size: 40),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Nothing saved yet.',
                            style: AppTextStyles.cardTitle,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Bookmark articles to read later.',
                            style: AppTextStyles.muted,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      itemCount: bookmarks.length,
                      itemBuilder: (context, index) {
                        return ArticleCard(article: bookmarks[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}