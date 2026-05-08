import 'package:html_unescape/html_unescape.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:webfeed_plus/webfeed_plus.dart';
import '../models/article.dart';
import '../../core/constants/feed_sources.dart';

class ArticleNormalizer {
  final _unescape = HtmlUnescape();

  Article fromRssItem(RssItem item, FeedSource source) {
    final article = Article()
      ..guid = _extractGuid(item)
      ..title = _cleanText(item.title) ?? 'Untitled'
      ..description = _extractDescription(item)
      ..url = item.link ?? ''
      ..imageUrl = _extractImage(item)
      ..sourceName = source.displayName
      ..sourceId = source.id
      ..category = source.category
      ..publishedAt = _parseRssDate(item.pubDate)
      ..cachedAt = DateTime.now()
      ..isRead = false
      ..isBookmarked = false
      ..readTimeMinutes = _estimateReadTime(item.description);

    return article;
  }

  Article fromAtomItem(AtomItem item, FeedSource source) {
    final article = Article()
      ..guid = item.id ?? item.links?.firstOrNull?.href ?? _fallbackGuid()
      ..title = _cleanText(item.title) ?? 'Untitled'
      ..description = _extractAtomDescription(item)
      ..url = item.links?.firstOrNull?.href ?? ''
      ..imageUrl = _extractAtomImage(item)
      ..sourceName = source.displayName
      ..sourceId = source.id
      ..category = source.category
      ..publishedAt = _parseAtomDate(item.updated) ?? _parseAtomDate(item.published) ?? DateTime.now()
      ..cachedAt = DateTime.now()
      ..isRead = false
      ..isBookmarked = false
      ..readTimeMinutes = _estimateReadTime(item.content);

    return article;
  }

  // --- Helpers ---

  String _extractGuid(RssItem item) {
    return item.guid ??
        item.link ??
        '${item.title}_${item.pubDate?.toString()}';
  }

  String _fallbackGuid() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  String? _cleanText(String? raw) {
    if (raw == null) return null;
    return _unescape.convert(
      raw.replaceAll(RegExp(r'<[^>]*>'), '').trim(),
    );
  }

  String? _extractDescription(RssItem item) {
    final raw = item.description ?? item.content?.value;
    if (raw == null) return null;
    final doc = html_parser.parse(raw);
    final text = doc.body?.text?.trim();
    if (text == null || text.isEmpty) return null;
    // Cap at 300 chars for preview
    return text.length > 300 ? '${text.substring(0, 300)}...' : text;
  }

  String? _extractAtomDescription(AtomItem item) {
    final raw = item.summary ?? item.content;
    if (raw == null) return null;
    final doc = html_parser.parse(raw);
    final text = doc.body?.text?.trim();
    if (text == null || text.isEmpty) return null;
    return text.length > 300 ? '${text.substring(0, 300)}...' : text;
  }

  String? _extractImage(RssItem item) {
    // Try media thumbnail first
    final mediaThumbnail = item.media?.thumbnails?.firstOrNull?.url;
    if (mediaThumbnail != null) return mediaThumbnail;

    // Try enclosure (podcasts / image attachments)
    final enclosure = item.enclosure?.url;
    if (enclosure != null && _isImageUrl(enclosure)) return enclosure;

    // Try scraping first <img> from description HTML
    return _extractImageFromHtml(item.description);
  }

  String? _extractAtomImage(AtomItem item) {
    return _extractImageFromHtml(item.content ?? item.summary);
  }

  String? _extractImageFromHtml(String? html) {
    if (html == null) return null;
    final doc = html_parser.parse(html);
    final img = doc.querySelector('img');
    final src = img?.attributes['src'];
    if (src != null && src.startsWith('http')) return src;
    return null;
  }

  bool _isImageUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  DateTime _parseRssDate(Object? date) {
    if (date == null) return DateTime.now();
    
    // If it's already a DateTime
    if (date is DateTime) return date;
    
    // If it's a String, try to parse it
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (_) {
        // Try RFC 822 parsing
        return _parseRfc822(date);
      }
    }
    
    // Fallback for any other type
    return DateTime.now();
  }

  DateTime? _parseAtomDate(Object? date) {
    if (date == null) return null;
    
    // If it's already a DateTime
    if (date is DateTime) return date;
    
    // If it's a String, try to parse it
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (_) {
        // Try RFC 822 parsing
        return _parseRfc822(date);
      }
    }
    
    // Fallback for any other type
    return null;
  }

  DateTime _parseRfc822(String raw) {
    // Example: "Mon, 02 Jan 2006 15:04:05 GMT"
    final months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
      'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
      'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
    
    try {
      final parts = raw.trim().split(' ');
      // Handle different formats
      if (parts.length < 5) return DateTime.now();
      
      final day = int.parse(parts[1]);
      final month = months[parts[2]] ?? 1;
      final year = int.parse(parts[3]);
      final timeParts = parts[4].split(':');
      
      return DateTime.utc(
        year, month, day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
      );
    } catch (e) {
      return DateTime.now();
    }
  }

  int _estimateReadTime(String? text) {
    if (text == null) return 1;
    final wordCount = text.trim().split(RegExp(r'\s+')).length;
    final minutes = (wordCount / 200).ceil();
    return minutes < 1 ? 1 : minutes;
  }
}