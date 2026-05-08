import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import '../../core/constants/feed_sources.dart';
import '../models/article.dart';
import 'article_normalizer.dart';
import 'package:flutter/foundation.dart';
class RssFetcher {
  final _normalizer = ArticleNormalizer();
  final _client = http.Client();

  Future<List<Article>> fetchFeed(FeedSource source) async {
    try {
      final response = await _client
          .get(Uri.parse(source.url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return [];

      final body = response.body;

      // Try RSS first, then Atom
      try {
        final rss = RssFeed.parse(body);
        return (rss.items ?? [])
            .map((item) => _normalizer.fromRssItem(item, source))
            .where((a) => a.url.isNotEmpty)
            .toList();
      } catch (_) {}

      try {
        final atom = AtomFeed.parse(body);
        return (atom.items ?? [])
            .map((item) => _normalizer.fromAtomItem(item, source))
            .where((a) => a.url.isNotEmpty)
            .toList();
      } catch (_) {}

      return [];
    } catch (e) {
      // Network error, timeout, bad XML — never crash the app
      debugPrint('Feed fetch failed for ${source.id}: $e');
      return [];
    }
  }

  Future<List<Article>> fetchAll(List<FeedSource> sources) async {
    final results = await Future.wait(
      sources.map((s) => fetchFeed(s)),
    );

    final all = results.expand((list) => list).toList();

    // Sort newest first
    all.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return all;
  }

  void dispose() => _client.close();
}