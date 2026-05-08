import 'package:hive/hive.dart';

part 'article.g.dart';

@HiveType(typeId: 0)
class Article extends HiveObject {
  @HiveField(0)
  late String guid;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late String url;

  @HiveField(4)
  String? imageUrl;

  @HiveField(5)
  late String sourceName;

  @HiveField(6)
  late String sourceId;

  @HiveField(7)
  late String category;

  @HiveField(8)
  late DateTime publishedAt;

  @HiveField(9)
  bool isRead = false;

  @HiveField(10)
  bool isBookmarked = false;

  @HiveField(11)
  late DateTime cachedAt;

  @HiveField(12)
  int readTimeMinutes = 1;
}