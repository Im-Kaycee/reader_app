import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/feed_provider.dart';
import '../../../ui/theme/app_theme.dart';
import '../home/widgets/article_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    // Clear search when leaving screen
    ref.read(searchQueryProvider.notifier).state = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: const Text('SEARCH.', style: AppTextStyles.headline),
            ),

            const SizedBox(height: 16),

            // Search input — neo-brut style
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkSurface
                      : AppColors.white,
                  border: Border.fromBorderSide(
                    BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkInk
                          : AppColors.ink,
                      width: 2,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkInk
                          : AppColors.ink,
                      offset: const Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(
                      Icons.search,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkInk
                          : AppColors.ink,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: dartTextField(
                        controller: _controller,
                        autofocus: true,
                        style: AppTextStyles.body.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkInk
                              : AppColors.ink,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search articles, sources...',
                          hintStyle: AppTextStyles.muted,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (val) {
                          ref.read(searchQueryProvider.notifier).state = val;
                        },
                      ),
                    ),
                    if (query.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _controller.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.close,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkInk
                                : AppColors.ink,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Container(height: 2, color: AppColors.ink),

            // Results
            Expanded(
              child: query.isEmpty
                  ? _buildEmptyState()
                  : results.isEmpty
                      ? _buildNoResults(query)
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 32),
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            return ArticleCard(article: results[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.ink, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.ink,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Icon(Icons.search, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('What are you looking for?',
              style: AppTextStyles.cardTitle),
          const SizedBox(height: 8),
          const Text('Search by title, source or category.',
              style: AppTextStyles.muted),
        ],
      ),
    );
  }

  Widget _buildNoResults(String query) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.ink, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.ink,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Icon(Icons.search_off, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('Nothing found.', style: AppTextStyles.cardTitle),
          const SizedBox(height: 8),
          Text(
            'No articles matching "$query".',
            style: AppTextStyles.muted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}