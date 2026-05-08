class FeedSource {
  final String id;
  final String displayName;
  final String url;
  final String category;

  const FeedSource({
    required this.id,
    required this.displayName,
    required this.url,
    required this.category,
  });
}

const List<FeedSource> kFeedSources = [
  // Tech
  FeedSource(
    id: 'hacker_news',
    displayName: 'Hacker News',
    url: 'https://news.ycombinator.com/rss',
    category: 'tech',
  ),
  FeedSource(
    id: 'ars_technica',
    displayName: 'Ars Technica',
    url: 'https://feeds.arstechnica.com/arstechnica/index',
    category: 'tech',
  ),
  FeedSource(
    id: 'the_verge',
    displayName: 'The Verge',
    url: 'https://www.theverge.com/rss/index.xml',
    category: 'tech',
  ),

  // Security
  FeedSource(
    id: 'krebs',
    displayName: 'Krebs on Security',
    url: 'https://krebsonsecurity.com/feed/',
    category: 'security',
  ),
  FeedSource(
    id: 'bleeping_computer',
    displayName: 'BleepingComputer',
    url: 'https://www.bleepingcomputer.com/feed/',
    category: 'security',
  ),

  // Music
  FeedSource(
    id: 'pitchfork',
    displayName: 'Pitchfork',
    url: 'https://pitchfork.com/feed/feed-news/rss',
    category: 'music',
  ),

  // Football
  FeedSource(
    id: 'bbc_football',
    displayName: 'BBC Football',
    url: 'https://feeds.bbci.co.uk/sport/football/rss.xml',
    category: 'football',
  ),
  FeedSource(
    id: 'guardian_football',
    displayName: 'The Guardian',
    url: 'https://www.theguardian.com/football/rss',
    category: 'football',
  ),
  FeedSource(
    id: 'espn_football',
    displayName: 'ESPN FC',
    url: 'https://www.espn.com/espn/rss/soccer/news',
    category: 'football',
  ),

  // General
  FeedSource(
    id: 'bbc',
    displayName: 'BBC News',
    url: 'https://feeds.bbci.co.uk/news/rss.xml',
    category: 'general',
  ),
  FeedSource(
    id: 'reuters',
    displayName: 'Reuters',
    url: 'https://feeds.reuters.com/reuters/topNews',
    category: 'general',
  ),
  // Nigeria
  FeedSource(
    id: 'punch',
    displayName: 'Punch Nigeria',
    url: 'https://punchng.com/feed/',
    category: 'nigeria',
  ),
  FeedSource(
    id: 'vanguard',
    displayName: 'Vanguard',
    url: 'https://www.vanguardngr.com/feed/',
    category: 'nigeria',
  ),
  FeedSource(
    id: 'the_cable',
    displayName: 'The Cable',
    url: 'https://www.thecable.ng/feed',
    category: 'nigeria',
  ),
  FeedSource(
    id: 'premium_times',
    displayName: 'Premium Times',
    url: 'https://www.premiumtimesng.com/feed',
    category: 'nigeria',
  ),
  FeedSource(
    id: 'channels_tv',
    displayName: 'Channels TV',
    url: 'https://www.channelstv.com/feed/',
    category: 'nigeria',
  ),
];



const List<String> kCategories = [
  'all',
  'tech',
  'security',
  'football',
  'music',
  'general',
  'nigeria',
];