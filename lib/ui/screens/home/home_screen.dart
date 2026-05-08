import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/feed_provider.dart';
import '../../../core/constants/feed_sources.dart';
import '../../../ui/theme/app_theme.dart';
import 'widgets/article_card.dart';
import 'widgets/category_tab_bar.dart';
import '../../../ui/widgets/offline_banner.dart';
import '../../../state/feed_provider.dart';
import '../../../ui/widgets/rabbit_hole_card.dart';
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    // When user is within 300px of the bottom, load next page
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      ref.read(feedProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('READER.', style: AppTextStyles.headline),
                  GestureDetector(
                    onTap: () => ref.read(feedProvider.notifier).refresh(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: AppColors.ink, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.ink,
                            offset: Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.refresh,
                          size: 20, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Category tabs
            CategoryTabBar(
              selected: selectedCategory,
              onSelect: (cat) {
                ref.read(selectedCategoryProvider.notifier).state = cat;
                ref.invalidate(feedProvider);
                _scrollController.jumpTo(0);
              },
            ),

            const SizedBox(height: 8),
            // Offline banner
            const OfflineBanner(),
            // Feed list
            Expanded(
              child: feedState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.ink),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Failed to load feed.',
                            style: AppTextStyles.cardTitle),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () =>
                              ref.read(feedProvider.notifier).refresh(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.ink,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.ink,
                                  offset: Offset(3, 3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: const Text(
                              'TRY AGAIN',
                              style: TextStyle(
                                color: AppColors.cream,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (articles) => RefreshIndicator(
                  color: AppColors.ink,
                  onRefresh: () => ref.read(feedProvider.notifier).refresh(),
                  child: articles.isEmpty
                      ? const Center(
                          child: Text(
                            'No articles yet.\nPull to refresh.',
                            style: AppTextStyles.muted,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Consumer(
                          builder: (context, ref, _) {
                            final rabbitHole = ref.watch(rabbitHoleProvider);

                            return ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                              itemCount: articles.length +
                                  (rabbitHole != null ? 2 : 1),
                              itemBuilder: (context, index) {
                                // First item — rabbit hole card
                                if (rabbitHole != null && index == 0) {
                                  return RabbitHoleCard(article: rabbitHole);
                                }

                                // Divider after rabbit hole
                                if (rabbitHole != null && index == 1) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 2,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            'YOUR FEED',
                                            style: AppTextStyles.label,
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 2,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                // Regular articles — offset index by rabbit hole + divider
                                final offset = rabbitHole != null ? 2 : 0;
                                final articleIndex = index - offset;

                                // Loading spinner at end
                                if (articleIndex == articles.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return ArticleCard(article: articles[articleIndex]);
                              },
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}