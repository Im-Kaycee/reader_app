import 'package:hive_flutter/hive_flutter.dart';
import '../models/article.dart';
import '../services/rss_fetcher.dart';
import '../../core/constants/feed_sources.dart';

class FeedRepository {
  static const _boxName = 'articles';
  static const _cacheAgeDays = 7;
  static const pageSize = 20;

  final _fetcher = RssFetcher();
  Box<Article>? _box;

  Future<void> init() async {
    _box = Hive.box<Article>(_boxName);
    await _pruneOldArticles();
  }

  Future<List<Article>> fetchAndCache({String? category}) async {
    final sources = category == null || category == 'all'
        ? kFeedSources
        : kFeedSources.where((s) => s.category == category).toList();

    final fresh = await _fetcher.fetchAll(sources);

    final box = _box!;
    for (final article in fresh) {
      final exists = box.values.any((a) => a.guid == article.guid);
      if (!exists) await box.add(article);
    }

    return getArticles(category: category);
  }

  // Paginated read from cache
  List<Article> getArticlesPage({
    String? category,
    required int page,
    Set<String> mutedSources = const {},
  }) {
    final all = getArticles(category: category, mutedSources: mutedSources);
    final start = page * pageSize;
    if (start >= all.length) return [];
    final end = (start + pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  List<Article> getArticles({
    String? category,
    Set<String> mutedSources = const {},
  }) {
    final box = _box!;
    var articles = box.values.toList();

    if (category != null && category != 'all') {
      articles = articles.where((a) => a.category == category).toList();
    }

    // Filter out muted sources
    if (mutedSources.isNotEmpty) {
      articles = articles
          .where((a) => !mutedSources.contains(a.sourceId))
          .toList();
    }

    articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return articles;
  }

  int getTotalCount({String? category}) {
    return getArticles(category: category).length;
  }

  List<Article> getBookmarks() {
    return _box!.values
        .where((a) => a.isBookmarked)
        .toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }

  Future<void> toggleBookmark(Article article) async {
    final box = _box!;
    final live = box.values.firstWhere(
      (a) => a.guid == article.guid,
      orElse: () => article,
    );
    live.isBookmarked = !live.isBookmarked;
    await live.save();
  }

  Future<void> markAsRead(Article article) async {
    article.isRead = true;
    await article.save();
  }

  Future<void> _pruneOldArticles() async {
    final box = _box!;
    final cutoff = DateTime.now().subtract(
      const Duration(days: _cacheAgeDays),
    );
    final toDelete = box.values
        .where((a) => a.cachedAt.isBefore(cutoff) && !a.isBookmarked)
        .toList();
    for (final article in toDelete) {
      await article.delete();
    }
  }

  void dispose() => _fetcher.dispose();
}
