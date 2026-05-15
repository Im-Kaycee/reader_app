# Reader

> Your personal corner of the internet.

A neo-brutalist RSS reader for Android. Built with Flutter. Free, offline-first, no ads, no algorithms — just the feeds you chose.

![Android](https://img.shields.io/badge/Android-5.0%2B-green)
![Flutter](https://img.shields.io/badge/Built%20with-Flutter-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## Download

[**→ Download Latest APK**](https://github.com/Im-Kaycee/reader_app/releases/latest)

No Play Store. No account. Just download and install.

---

## What it does

Reader aggregates RSS feeds from sources you actually care about into one fast, beautiful, offline-ready experience.

### Categories

| Category | Sources |
|---|---|
| Tech | Hacker News, Ars Technica, The Verge, Wired, MIT Tech Review, TechCabal |
| Security | Krebs on Security, BleepingComputer |
| Football | BBC Football, The Guardian, ESPN FC |
| Music | Pitchfork |
| Nigeria | Punch, Vanguard, The Cable, Premium Times, Channels TV, Nairametrics |
| General | BBC News, Reuters |

### Features

- RSS aggregation across 15+ feeds
- Offline reading — articles cached for 7 days
- Today's Rabbit Hole — one deep article surfaced daily
- Bookmarks — saved permanently on device
- Mute sources — toggle any feed off from settings
- Full-text search across all cached articles
- Live Naira exchange rates (USD, GBP, EUR → NGN)
- Dark mode (Light / Dark / System)
- In-app update notifications
- Zero tracking. Zero ads. Zero backend.

---

## How to install

1. Download the APK from [Releases](https://github.com/Im-Kaycee/reader_app/releases/latest)
2. On your Android phone go to **Settings → Security → Install unknown apps**
3. Allow installation from your browser or file manager
4. Open the downloaded file and tap **Install**
5. Open Reader and pull down to load your feeds

> Android will show a security warning — this is normal for apps installed outside the Play Store. Tap "Install anyway" to proceed. Reader makes no network requests outside of your RSS feeds and the exchange rate API.

---

## Tech stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State management | Riverpod |
| Local database | Hive |
| RSS parsing | webfeed_plus |
| Navigation | go_router |
| Images | cached_network_image |
| HTML rendering | flutter_html |
| Connectivity | connectivity_plus |
| Exchange rates | open.er-api.com (free tier) |

---

## Architecture

```
RSS Feeds
  → RssFetcher (http + retry)
  → ArticleNormalizer (tolerant parsing)
  → FeedRepository (cache + dedup)
  → Riverpod Providers (state)
  → UI (Flutter widgets)
```

**Key decisions:**

- **Repository pattern** — UI never touches the network or database directly
- **Cache-first strategy** — cached articles load instantly, fresh content updates in the background (stale-while-revalidate)
- **Tolerant parsing** — handles malformed dates, missing images, bad HTML, and encoding issues without crashing
- **No backend** — everything runs on device. Hive stores articles (7-day TTL), bookmarks (permanent), and user preferences

---

## Project structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── feed_sources.dart     # all RSS feed URLs + metadata
│   │   ├── app_version.dart      # version string + update check URL
│   │   └── theme.dart
│   └── utils/
│       └── transitions.dart      # slide-up page transition
├── data/
│   ├── models/
│   │   └── article.dart          # Hive collection
│   ├── repositories/
│   │   └── feed_repository.dart  # cache + dedup + pagination
│   └── services/
│       ├── rss_fetcher.dart       # HTTP + parallel fetch
│       ├── article_normalizer.dart
│       ├── exchange_rate_service.dart
│       └── update_service.dart
├── state/
│   └── feed_provider.dart        # all Riverpod providers
└── ui/
    ├── screens/
    │   ├── home/                  # feed + category tabs
    │   ├── reader/                # article detail + WebView
    │   ├── search/
    │   ├── bookmarks/
    │   ├── settings/
    │   └── shell/                 # bottom nav shell
    ├── widgets/
    │   ├── brut_card.dart
    │   ├── offline_banner.dart
    │   ├── rabbit_hole_card.dart
    │   └── exchange_rate_card.dart
    └── theme/
        └── app_theme.dart         # AppColors, AppTextStyles, AppTheme
```

---

## Running locally

```bash
# Clone
git clone https://github.com/Im-Kaycee/reader_app.git
cd reader_app

# Install dependencies
flutter pub get

# Generate Hive adapters
dart run build_runner build --delete-conflicting-outputs

# Run on connected device or emulator
flutter run

# Build release APK (Android arm64)
flutter build apk --release --target-platform android-arm64
```

**Requirements:**
- Flutter 3.x stable
- Android SDK (for device builds)
- A connected Android device or emulator

---

## Releasing an update

1. Bump version in `pubspec.yaml` — e.g. `version: 1.3.0+4`
2. Update `lib/core/constants/app_version.dart` — `kAppVersion = '1.3.0'`
3. Update `version.json` in repo root with new version + download URL
4. Build: `flutter build apk --release --target-platform android-arm64`
5. Create a GitHub Release tagged `v1.3.0`
6. Attach the APK as `reader-v1.3.apk`
7. Users on older versions will see the update banner automatically on next app open

---

## Roadmap

- [ ] Reddit feed integration
- [ ] Text-to-speech reading mode
- [ ] Terminal-style reading mode
- [ ] Read time filter (short reads / long reads)
- [ ] Tablet layout

---

## License

MIT — do whatever you want with it.

---

Built by [@Im-Kaycee](https://github.com/Im-Kaycee)
