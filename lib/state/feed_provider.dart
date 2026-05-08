import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/article.dart';
import '../data/repositories/feed_repository.dart';
import '../data/services/exchange_rate_service.dart';
import 'package:flutter/material.dart';
import '../data/services/update_service.dart';
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final repo = FeedRepository();
  ref.onDispose(() => repo.dispose());
  return repo;
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'all');
final feedPageProvider = StateProvider<int>((ref) => 0);

// --- Bookmarks ---
// Holds the set of bookmarked guids — rebuilds UI when changed
final bookmarkGuidsProvider =
    StateNotifierProvider<BookmarkGuidsNotifier, Set<String>>(
  (ref) {
    final repo = ref.watch(feedRepositoryProvider);
    return BookmarkGuidsNotifier(repo);
  },
);

class BookmarkGuidsNotifier extends StateNotifier<Set<String>> {
  final FeedRepository _repo;

  BookmarkGuidsNotifier(this._repo) : super({}) {
    _load();
  }

  void _load() {
    final bookmarked = _repo.getBookmarks().map((a) => a.guid).toSet();
    state = bookmarked;
  }

  Future<void> toggle(Article article) async {
    await _repo.toggleBookmark(article);
    final bookmarked = _repo.getBookmarks().map((a) => a.guid).toSet();
    state = bookmarked;
  }
}

// Reactive bookmarks list
final bookmarksProvider = Provider<List<Article>>((ref) {
  // Re-runs whenever bookmarkGuids changes
  ref.watch(bookmarkGuidsProvider);
  final repo = ref.watch(feedRepositoryProvider);
  return repo.getBookmarks();
});

// --- Feed ---
final feedProvider = AsyncNotifierProvider<FeedNotifier, List<Article>>(
  FeedNotifier.new,
);

class FeedNotifier extends AsyncNotifier<List<Article>> {
  @override
  Future<List<Article>> build() async {
    final repo = ref.watch(feedRepositoryProvider);
    await repo.init();

    final category = ref.watch(selectedCategoryProvider);
    final muted = ref.watch(mutedSourcesProvider);
    ref.read(feedPageProvider.notifier).state = 0;

    final cached = repo.getArticlesPage(
      category: category,
      page: 0,
      mutedSources: muted,
    );
    if (cached.isNotEmpty) {
      _refreshInBackground(category);
      return cached;
    }

    return repo.fetchAndCache(category: category).then((_) =>
        repo.getArticlesPage(
          category: category,
          page: 0,
          mutedSources: muted,
        ));
  }

  Future<void> refresh() async {
    final category = ref.read(selectedCategoryProvider);
    final repo = ref.read(feedRepositoryProvider);
    final muted = ref.read(mutedSourcesProvider);
    ref.read(feedPageProvider.notifier).state = 0;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.fetchAndCache(category: category);
      return repo.getArticlesPage(
        category: category,
        page: 0,
        mutedSources: muted,
      );
    });
  }

  void loadNextPage() {
    final current = state.valueOrNull;
    if (current == null) return;

    final category = ref.read(selectedCategoryProvider);
    final repo = ref.read(feedRepositoryProvider);
    final muted = ref.read(mutedSourcesProvider);
    final nextPage = ref.read(feedPageProvider) + 1;
    final more = repo.getArticlesPage(
      category: category,
      page: nextPage,
      mutedSources: muted,
    );

    if (more.isEmpty) return;

    ref.read(feedPageProvider.notifier).state = nextPage;
    state = AsyncValue.data([...current, ...more]);
  }

  void _refreshInBackground(String category) {
    final repo = ref.read(feedRepositoryProvider);
    final muted = ref.read(mutedSourcesProvider);
    repo.fetchAndCache(category: category).then((_) {
      final fresh = repo.getArticlesPage(
        category: category,
        page: 0,
        mutedSources: muted,
      );
      if (fresh.isNotEmpty) {
        ref.read(feedPageProvider.notifier).state = 0;
        state = AsyncValue.data(fresh);
      }
    });
  }
}
// --- Muted sources ---
final mutedSourcesProvider =
    StateNotifierProvider<MutedSourcesNotifier, Set<String>>(
  (ref) => MutedSourcesNotifier(),
);

class MutedSourcesNotifier extends StateNotifier<Set<String>> {
  static const _boxName = 'prefs';
  static const _mutedKey = 'muted_sources';

  MutedSourcesNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox(_boxName);
    final saved = box.get(_mutedKey, defaultValue: <String>[]) as List;
    state = saved.cast<String>().toSet();
  }

  Future<void> _save() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_mutedKey, state.toList());
  }

  void toggle(String sourceId) {
    if (state.contains(sourceId)) {
      state = {...state}..remove(sourceId);
    } else {
      state = {...state, sourceId};
    }
    _save();
  }

  bool isMuted(String sourceId) => state.contains(sourceId);
}
// --- Search ---
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<List<Article>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final repo = ref.watch(feedRepositoryProvider);
  final muted = ref.watch(mutedSourcesProvider);

  if (query.isEmpty) return [];

  final all = repo.getArticles(mutedSources: muted);
  return all
      .where((a) =>
          a.title.toLowerCase().contains(query) ||
          a.sourceName.toLowerCase().contains(query) ||
          a.category.toLowerCase().contains(query) ||
          (a.description?.toLowerCase().contains(query) ?? false))
      .toList();
});
// --- Rabbit Hole ---
final rabbitHoleProvider = Provider<Article?>((ref) {
  ref.watch(bookmarkGuidsProvider); // refresh when bookmarks change
  final repo = ref.watch(feedRepositoryProvider);
  final muted = ref.watch(mutedSourcesProvider);
  final all = repo.getArticles(mutedSources: muted);

  if (all.isEmpty) return null;

  // Filter unread articles only
  final unread = all.where((a) => !a.isRead).toList();
  if (unread.isEmpty) return null;

  // Prefer longer reads (3+ mins)
  final longReads = unread.where((a) => a.readTimeMinutes >= 3).toList();
  final pool = longReads.isNotEmpty ? longReads : unread;

  // Pick based on today's date as seed so it stays consistent all day
  final today = DateTime.now();
  final seed = today.year * 10000 + today.month * 100 + today.day;
  final index = seed % pool.length;

  return pool[index];
});
// --- Exchange Rates ---
final exchangeRateProvider =
    AsyncNotifierProvider<ExchangeRateNotifier, List<ExchangeRate>>(
  ExchangeRateNotifier.new,
);

class ExchangeRateNotifier extends AsyncNotifier<List<ExchangeRate>> {
  @override
  Future<List<ExchangeRate>> build() async {
    return ExchangeRateService().fetchRates();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ExchangeRateService().fetchRates(),
    );
  }
}
// --- Theme ---
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const _boxName = 'prefs';
  static const _themeKey = 'theme_mode';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox(_boxName);
    final saved = box.get(_themeKey, defaultValue: 'system') as String;
    state = _fromString(saved);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final box = await Hive.openBox(_boxName);
    await box.put(_themeKey, _toString(mode));
  }

  ThemeMode _fromString(String s) {
    switch (s) {
      case 'light':  return ThemeMode.light;
      case 'dark':   return ThemeMode.dark;
      default:       return ThemeMode.system;
    }
  }

  String _toString(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:  return 'light';
      case ThemeMode.dark:   return 'dark';
      default:               return 'system';
    }
  }
}
// --- Update Check ---
final updateProvider = FutureProvider<UpdateInfo?>((ref) async {
  return UpdateService().checkForUpdate();
});