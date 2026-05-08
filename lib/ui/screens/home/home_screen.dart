import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../state/feed_provider.dart';
import '../../../core/constants/feed_sources.dart';
import '../../../ui/theme/app_theme.dart';
import 'widgets/article_card.dart';
import 'widgets/category_tab_bar.dart';
import '../../../ui/widgets/offline_banner.dart';
import '../../../state/feed_provider.dart';
import '../../../ui/widgets/rabbit_hole_card.dart';
import '../../../ui/widgets/exchange_rate_card.dart';
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
            // Update banner
            const _UpdateBanner(),
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
                            final selectedCategory = ref.watch(selectedCategoryProvider);
                            final showRates = selectedCategory == 'nigeria';

                            int topItems = 0;
                            if (rabbitHole != null) topItems += 2; // card + divider
                            if (showRates) topItems += 1;

                            return ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                              itemCount: articles.length + topItems + 1,
                              itemBuilder: (context, index) {
                                int offset = 0;

                                // Exchange rate card — only on Nigeria tab, first item
                                if (showRates && index == 0) {
                                  return const ExchangeRateCard();
                                }
                                if (showRates) offset += 1;

                                // Rabbit hole card
                                if (rabbitHole != null && index == offset) {
                                  return RabbitHoleCard(article: rabbitHole);
                                }

                                // Divider after rabbit hole
                                if (rabbitHole != null && index == offset + 1) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      children: [
                                        Expanded(child: Container(height: 2, color: AppColors.ink)),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Text('YOUR FEED', style: AppTextStyles.label),
                                        ),
                                        Expanded(child: Container(height: 2, color: AppColors.ink)),
                                      ],
                                    ),
                                  );
                                }
                                if (rabbitHole != null) offset += 2;

                                final articleIndex = index - offset;
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

class _UpdateBanner extends ConsumerWidget {
  const _UpdateBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(updateProvider);

    return updateState.maybeWhen(
      data: (info) {
        if (info == null || !info.hasUpdate) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () async {
            final uri = Uri.parse(info.downloadUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 12,
            ),
            color: AppColors.tech,
            child: Row(
              children: [
                const Text('⬆️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UPDATE AVAILABLE — v${info.latestVersion}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: AppColors.ink,
                        ),
                      ),
                      if (info.releaseNotes.isNotEmpty)
                        Text(
                          info.releaseNotes,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const Text(
                  'TAP TO DOWNLOAD →',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}