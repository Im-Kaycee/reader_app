import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../state/feed_provider.dart';
import '../../../ui/theme/app_theme.dart';
import 'webview_screen.dart';
import 'package:flutter/foundation.dart';
class ReaderScreen extends ConsumerStatefulWidget {
  final Article article;

  const ReaderScreen({super.key, required this.article});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late Article _article;

  @override
  void initState() {
    super.initState();
    _article = widget.article;
    _markAsRead();
  }

  Future<void> _markAsRead() async {
    if (!_article.isRead) {
      final repo = ref.read(feedRepositoryProvider);
      await repo.markAsRead(_article);
      setState(() => _article.isRead = true);
    }
  }

Future<void> _toggleBookmark() async {
  await ref.read(bookmarkGuidsProvider.notifier).toggle(_article);
}

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(_article.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openInApp() {
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebViewScreen(
          url: _article.url,
          title: _article.sourceName,
        ),
      ),
    );
  } else {
    _openInBrowser();
  }
}

  void _share() {
    Share.share('${_article.title}\n\n${_article.url}');
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.forCategory(_article.category);
    final isBookmarked = ref.watch(bookmarkGuidsProvider).contains(_article.guid);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  // Back button
                 GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
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
                      child: const Icon(Icons.arrow_back, size: 20, color: AppColors.ink),
                    ),
                  ),

                  const Spacer(),

                  // Share button
                  GestureDetector(
                    onTap: _share,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.ink, width: 2),
                      ),
                      child: const Icon(Icons.share, size: 20),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Bookmark button
                  GestureDetector(
                      onTap: _toggleBookmark,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isBookmarked ? AppColors.ink : AppColors.cream,
                          border: Border.all(color: AppColors.ink, width: 2),
                          boxShadow: isBookmarked
                              ? [
                                  BoxShadow(
                                    color: accent,
                                    offset: const Offset(3, 3),
                                    blurRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          size: 20,
                          color: isBookmarked ? AppColors.cream : AppColors.ink,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Article content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category + source badge
                    Row(
                      children: [
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          color: accent,
                          child: Text(
                            _article.category.toUpperCase(),
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.labelColorFor(accent),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.ink, width: 1.5,
                            ),
                          ),
                          child: Text(
                            _article.sourceName.toUpperCase(),
                            style: AppTextStyles.label,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Title
                    Text(_article.title, style: AppTextStyles.headline),

                    const SizedBox(height: 16),

                    // Meta row
                    Row(
                      children: [
                        Text(
                          _formatDate(_article.publishedAt),
                          style: AppTextStyles.muted,
                        ),
                        const SizedBox(width: 8),
                        Text('·', style: AppTextStyles.muted),
                        const SizedBox(width: 8),
                        Text(
                          '${_article.readTimeMinutes} min read',
                          style: AppTextStyles.muted,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Container(height: 2, color: AppColors.ink),

                    const SizedBox(height: 20),

                    // Hero image
                    if (_article.imageUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.ink, width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.ink,
                                offset: Offset(5, 5),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: CachedNetworkImage(
                            imageUrl: _article.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),

                    // Description / body
                    if (_article.description != null)
                      Html(
                        data: _article.description!,
                        style: {
                          'body': Style(
                            fontSize: FontSize(16),
                            lineHeight: LineHeight(1.7),
                            color: AppColors.ink,
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                          ),
                          'p': Style(
                            margin: Margins.only(bottom: 16),
                          ),
                          'a': Style(
                            color: accent,
                            textDecoration: TextDecoration.underline,
                          ),
                        },
                      )
                    else
                      Text(
                        'No preview available.',
                        style: AppTextStyles.muted,
                      ),

                    const SizedBox(height: 32),

                    // Two action buttons
                    Row(
                      children: [
                        // Read in app
                        Expanded(
                          child: GestureDetector(
                            onTap: _openInApp,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.ink,
                                boxShadow: [
                                  BoxShadow(
                                    color: accent,
                                    offset: const Offset(5, 5),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.article,
                                      color: AppColors.cream, size: 18),
                                  SizedBox(height: 4),
                                  Text(
                                    'READ IN APP',
                                    style: TextStyle(
                                      color: AppColors.cream,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Open in browser
                        Expanded(
                          child: GestureDetector(
                            onTap: _openInBrowser,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.cream,
                                border: Border.all(
                                    color: AppColors.ink, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.ink,
                                    offset: Offset(5, 5),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.open_in_new,
                                      color: AppColors.ink, size: 18),
                                  SizedBox(height: 4),
                                  Text(
                                    'OPEN IN BROWSER',
                                    style: TextStyle(
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}